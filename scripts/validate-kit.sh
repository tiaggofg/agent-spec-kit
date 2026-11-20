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
  "core/.agents/rules/feature-naming-and-quality.md"
  "core/.agents/scripts/validate-feature-name.sh"
  "core/.agents/scripts/quality-check.sh"
  "core/.agents/scripts/validate-commit-msg.sh"
  "core/.agents/skills/implement-spec-tasks/SKILL.md"
  "core/.agents/skills/grill-me/SKILL.md"
  "core/.agents/skills/grilling/SKILL.md"
  "core/skills/tlc-spec-driven/SKILL.md"
  "templates/AGENTS.md"
  "templates/.specs/STATE.md"
  "templates/docs/README.md"
  "templates/docs/arquitetura-c4.md"
  "templates/docs/modelo-dominio-e-dados.md"
  "templates/docs/fluxos-e-sequencias.md"
  "templates/docs/api-rest.md"
  "templates/docs/seguranca-e-privacidade.md"
  "templates/docs/deploy-e-ci-cd.md"
  "templates/docs/adr/README.md"
  "templates/docs/adr/0000-template.md"
  "templates/.sonarqube/docker-compose.yml"
  "templates/.sonarqube/.gitignore"
  "templates/sonar-project.properties"
  "templates/.github/workflows/release.yml"
  "templates/release-please-config.json"
  "templates/.release-please-manifest.json"
)

for f in "${required_files[@]}"; do
  if [[ ! -f "$KIT_DIR/$f" ]]; then
    echo "FAIL: Missing required file $f" >&2
    exit 1
  fi
done

bash -n "$KIT_DIR/scripts/install.sh"
bash -n "$KIT_DIR/core/.agents/scripts/validate-feature-name.sh"
bash -n "$KIT_DIR/core/.agents/scripts/quality-check.sh"
bash -n "$KIT_DIR/core/.agents/scripts/validate-commit-msg.sh"
echo "OK: bash syntax valid for all scripts"

if command -v python3 >/dev/null 2>&1; then
  python3 "$KIT_DIR/core/skills/tlc-spec-driven/scripts/selftest.py"
  echo "OK: tlc-spec-driven selftest.py passed"
fi

echo "All kit validations passed!"
