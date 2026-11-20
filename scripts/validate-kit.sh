#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Validating agent-spec-kit at $KIT_DIR..."

required_files=(
  "VERSION"
  "README.md"
  "CHANGELOG.md"
  "scripts/install.sh"
  "core/.agents/rules/post-implementation-testing.md"
  "core/.agents/rules/spec-handoff-only.md"
  "core/.agents/rules/post-cycle-approval-and-docs.md"
  "core/.agents/skills/implement-spec-tasks/SKILL.md"
  "core/.agents/skills/grill-me/SKILL.md"
  "core/.agents/skills/grilling/SKILL.md"
  "core/skills/tlc-spec-driven/SKILL.md"
  "templates/AGENTS.md"
  "templates/.specs/STATE.md"
)

for f in "${required_files[@]}"; do
  if [[ ! -f "$KIT_DIR/$f" ]]; then
    echo "FAIL: Missing required file $f" >&2
    exit 1
  fi
done

bash -n "$KIT_DIR/scripts/install.sh"
echo "OK: install.sh bash syntax valid"

if command -v python3 >/dev/null 2>&1; then
  python3 "$KIT_DIR/core/skills/tlc-spec-driven/scripts/selftest.py"
  echo "OK: tlc-spec-driven selftest.py passed"
fi

echo "All kit validations passed!"
