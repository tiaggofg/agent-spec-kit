#!/usr/bin/env bash
set -euo pipefail

DEFAULT_REPO="https://github.com/tiaggofg/agent-spec-kit.git"
DEFAULT_REF="main"
DEFAULT_IDES="none"

TARGET_DIR="."
REPO_URL=""
REF=""
IDES=""
LOCAL_KIT=""
DRY_RUN=false
FORCE_TEMPLATES=false
SKIP_TOOLS=false
UP_SONAR=false

usage() {
  cat <<'EOF'
agent-spec-kit installer & updater

Usage:
  install.sh [options]

Options:
  --target <dir>       Target project directory (default: .)
  --repo <git-url>     Git repository URL of agent-spec-kit
  --ref <branch|tag>   Git branch or tag to fetch (default: main)
  --ides <csv>         Extra IDE skill dirs to mirror: claude,cursor,windsurf,all,none (default: none; .agents/ is always synced for Antigravity)
  --local <dir>        Use a local agent-spec-kit directory instead of cloning from Git
  --skip-tools         Skip .sonarqube/ and sonar-project.properties setup
  --up-sonar           Start local SonarQube container immediately after install
  --dry-run            Show planned actions without modifying any files
  --force-templates    Overwrite AGENTS.md and .specs/STATE.md even if they already exist
  -h, --help           Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --repo)
      REPO_URL="$2"
      shift 2
      ;;
    --ref)
      REF="$2"
      shift 2
      ;;
    --ides)
      IDES="$2"
      shift 2
      ;;
    --local)
      LOCAL_KIT="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-tools)
      SKIP_TOOLS=true
      shift
      ;;
    --up-sonar)
      UP_SONAR=true
      shift
      ;;
    --force-templates)
      FORCE_TEMPLATES=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown option '$1'" >&2
      usage >&2
      exit 1
      ;;
  esac
done

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
CONFIG_FILE="$TARGET_DIR/.spec-kit.json"

read_config_field() {
  local field="$1"
  if [[ -f "$CONFIG_FILE" ]]; then
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$CONFIG_FILE" "$field" <<'PY' 2>/dev/null || true
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
val = data.get(sys.argv[2], "")
if isinstance(val, list):
    print(",".join(val))
else:
    print(val)
PY
    else
      sed -nE "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*/\1/p" "$CONFIG_FILE" | head -n 1 || true
    fi
  fi
}

if [[ -z "$REPO_URL" ]]; then
  REPO_URL="$(read_config_field repo)"
  [[ -z "$REPO_URL" ]] && REPO_URL="$DEFAULT_REPO"
fi

if [[ -z "$REF" ]]; then
  REF="$(read_config_field ref)"
  [[ -z "$REF" ]] && REF="$DEFAULT_REF"
fi

if [[ -z "$IDES" ]]; then
  IDES="$(read_config_field ides)"
  [[ -z "$IDES" ]] && IDES="$DEFAULT_IDES"
fi

TMP_DIR=""
cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

KIT_DIR=""
if [[ -n "$LOCAL_KIT" ]]; then
  KIT_DIR="$(cd "$LOCAL_KIT" && pwd)"
elif [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/../core" && -d "$SCRIPT_DIR/../templates" ]]; then
  KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  TMP_DIR="$(mktemp -d)"
  echo "Fetching agent-spec-kit ($REF) from $REPO_URL..."
  git clone --depth 1 --branch "$REF" "$REPO_URL" "$TMP_DIR/kit" >/dev/null 2>&1
  KIT_DIR="$TMP_DIR/kit"
fi

if [[ ! -d "$KIT_DIR/core" || ! -d "$KIT_DIR/templates" ]]; then
  echo "Error: Invalid kit directory '$KIT_DIR' (missing core/ or templates/)." >&2
  exit 1
fi

KIT_VERSION="unknown"
if [[ -f "$KIT_DIR/VERSION" ]]; then
  KIT_VERSION="$(tr -d '[:space:]' < "$KIT_DIR/VERSION")"
fi

PREV_VERSION="$(read_config_field version)"

echo "agent-spec-kit v$KIT_VERSION -> $TARGET_DIR"
if [[ -n "$PREV_VERSION" ]]; then
  echo "Previous installed version: v$PREV_VERSION"
fi
if [[ "$DRY_RUN" == "true" ]]; then
  echo "[DRY-RUN] No files will be modified."
fi

sync_item() {
  local src="$1"
  local dst="$2"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [sync] $dst"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  cp -R "$src" "$dst"
}

# 1. Sync .agents/rules/
for rule in "$KIT_DIR"/core/.agents/rules/*.md; do
  [[ -e "$rule" ]] || continue
  sync_item "$rule" "$TARGET_DIR/.agents/rules/$(basename "$rule")"
done

# 1b. Sync .agents/scripts/
for script in "$KIT_DIR"/core/.agents/scripts/*; do
  [[ -e "$script" ]] || continue
  dst_script="$TARGET_DIR/.agents/scripts/$(basename "$script")"
  sync_item "$script" "$dst_script"
  if [[ "$DRY_RUN" != "true" && -f "$dst_script" ]]; then
    chmod +x "$dst_script"
  fi
done

# 2. Sync .agents/skills/ (Antigravity primary discovery: all kit skills)
for skill in "$KIT_DIR"/core/.agents/skills/* "$KIT_DIR"/core/skills/*; do
  [[ -d "$skill" ]] || continue
  sync_item "$skill" "$TARGET_DIR/.agents/skills/$(basename "$skill")"
done

# 3. Sync optional extra IDE mirrors (.claude, .cursor, .windsurf)
if [[ "$IDES" == "all" ]]; then
  IDES="claude,cursor,windsurf"
fi

if [[ "$IDES" != "none" && -n "$IDES" ]]; then
  IFS=',' read -ra IDE_LIST <<< "$IDES"
  for ide in "${IDE_LIST[@]}"; do
    ide_trimmed="$(echo "$ide" | tr -d '[:space:]')"
    [[ -z "$ide_trimmed" || "$ide_trimmed" == "none" ]] && continue
    for skill in "$KIT_DIR"/core/skills/* "$KIT_DIR"/core/.agents/skills/*; do
      [[ -d "$skill" ]] || continue
      sync_item "$skill" "$TARGET_DIR/.$ide_trimmed/skills/$(basename "$skill")"
    done
  done
fi

# 4. Copy project-owned templates ONLY if missing (unless --force-templates)
copy_template_if_missing() {
  local src="$1"
  local dst="$2"
  if [[ -f "$dst" && "$FORCE_TEMPLATES" != "true" ]]; then
    echo "  [keep] $dst (already exists)"
    return
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [init] $dst"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "  [init] $dst"
}

copy_template_if_missing "$KIT_DIR/templates/AGENTS.md" "$TARGET_DIR/AGENTS.md"
copy_template_if_missing "$KIT_DIR/templates/.specs/STATE.md" "$TARGET_DIR/.specs/STATE.md"

if [[ "$SKIP_TOOLS" != "true" ]]; then
  copy_template_if_missing "$KIT_DIR/templates/.sonarqube/docker-compose.yml" "$TARGET_DIR/.sonarqube/docker-compose.yml"
  copy_template_if_missing "$KIT_DIR/templates/.sonarqube/.gitignore" "$TARGET_DIR/.sonarqube/.gitignore"
  copy_template_if_missing "$KIT_DIR/templates/.github/workflows/release.yml" "$TARGET_DIR/.github/workflows/release.yml"
  copy_template_if_missing "$KIT_DIR/templates/release-please-config.json" "$TARGET_DIR/release-please-config.json"
  copy_template_if_missing "$KIT_DIR/templates/.release-please-manifest.json" "$TARGET_DIR/.release-please-manifest.json"

  if [[ "$DRY_RUN" != "true" && -d "$TARGET_DIR/.git/hooks" && ! -f "$TARGET_DIR/.git/hooks/commit-msg" ]]; then
    cat > "$TARGET_DIR/.git/hooks/commit-msg" <<'HOOK'
#!/usr/bin/env bash
exec "$(git rev-parse --show-toplevel)/.agents/scripts/validate-commit-msg.sh" "$1"
HOOK
    chmod +x "$TARGET_DIR/.git/hooks/commit-msg"
    echo "  [hook] $TARGET_DIR/.git/hooks/commit-msg"
  fi

  SONAR_PROPS="$TARGET_DIR/sonar-project.properties"
  if [[ ! -f "$SONAR_PROPS" || "$FORCE_TEMPLATES" == "true" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "  [init] $SONAR_PROPS"
    else
      PROJECT_KEY="$(basename "$TARGET_DIR" | tr -cs 'a-zA-Z0-9._-' '-' | sed 's/^-//;s/-$//')"
      PROJECT_KEY="${PROJECT_KEY:-my-project}"
      sed "s/__PROJECT_KEY__/${PROJECT_KEY}/g" "$KIT_DIR/templates/sonar-project.properties" > "$SONAR_PROPS"
      echo "  [init] $SONAR_PROPS (projectKey=$PROJECT_KEY)"
    fi
  else
    echo "  [keep] $SONAR_PROPS (already exists)"
  fi
fi

if [[ "$DRY_RUN" == "true" ]]; then
  echo "  [write] $TARGET_DIR/.spec-kit.json"
  echo "  [write] $TARGET_DIR/.agents/update-spec-kit.sh"
  echo "Dry run complete."
  exit 0
fi

# 5. Write .spec-kit.json metadata
UPDATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
cat > "$CONFIG_FILE" <<EOF
{
  "version": "$KIT_VERSION",
  "repo": "$REPO_URL",
  "ref": "$REF",
  "ides": "$IDES",
  "updatedAt": "$UPDATED_AT"
}
EOF

# 6. Write helper update script inside .agents/
UPDATE_SCRIPT="$TARGET_DIR/.agents/update-spec-kit.sh"
cat > "$UPDATE_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Updates managed harness rules & skills from agent-spec-kit without overwriting AGENTS.md or .specs/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$TARGET_DIR/.spec-kit.json"

REPO_URL="$(sed -nE 's/.*"repo"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' "$CONFIG_FILE" | head -n 1)"
REF="$(sed -nE 's/.*"ref"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' "$CONFIG_FILE" | head -n 1)"

REPO_URL="${REPO_URL:-https://github.com/tiaggofg/agent-spec-kit.git}"
REF="${REF:-main}"

LOCAL_KIT=""
EXTRA_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      LOCAL_KIT="$2"
      shift 2
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ -n "$LOCAL_KIT" ]]; then
  exec bash "$LOCAL_KIT/scripts/install.sh" --target "$TARGET_DIR" --local "$LOCAL_KIT" "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
git clone --depth 1 --branch "$REF" "$REPO_URL" "$TMP_DIR/kit" >/dev/null 2>&1
exec bash "$TMP_DIR/kit/scripts/install.sh" --target "$TARGET_DIR" --local "$TMP_DIR/kit" "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
EOF
chmod +x "$UPDATE_SCRIPT"

echo "Done! Managed harness updated to v$KIT_VERSION."
echo "To update this project later, run: ./.agents/update-spec-kit.sh"

if [[ "$SKIP_TOOLS" != "true" ]]; then
  echo ""
  echo "Tooling setup:"
  for tool in docker python3 curl; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "  [ok] $tool"
    else
      echo "  [missing] $tool (required for local SonarQube / deterministic gates)"
    fi
  done
  if [[ "$UP_SONAR" == "true" ]] && command -v docker >/dev/null 2>&1; then
    echo "Starting local SonarQube..."
    docker compose -f "$TARGET_DIR/.sonarqube/docker-compose.yml" up -d
  else
    echo "  Start local SonarQube: docker compose -f .sonarqube/docker-compose.yml up -d"
  fi
  echo "  Run quality gate:      ./.agents/scripts/quality-check.sh --up"
fi
