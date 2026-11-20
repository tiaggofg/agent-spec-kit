# Changelog

## [1.2.0] - 2026-11-20

### Added
- **Feature folder naming rule & validator**: `.specs/features/<feature>/` must match `^[0-9]+-[a-zA-Z][a-zA-Z0-9-]*$` (e.g., `01-user-auth`), enforced via `.agents/rules/feature-naming-and-quality.md` and `.agents/scripts/validate-feature-name.sh`.
- **Deterministic Static Analysis (Lint + Local SonarQube)**:
  - `.agents/scripts/quality-check.sh` runs project lint checks and queries local SonarQube Quality Gate & open issues via REST API (`/api/qualitygates/project_status`, `/api/issues/search`).
  - `templates/.sonarqube/docker-compose.yml` (`sonarqube:lts-community` with local bind-mounted volumes under `.sonarqube/volumes/`), `.sonarqube/.gitignore`, and `sonar-project.properties` template.
  - `scripts/install.sh` sets up `.sonarqube/`, `sonar-project.properties`, `.agents/scripts/`, and checks `docker`/`python3`/`curl` availability (with `--skip-tools` and `--up-sonar` flags).

## [1.1.0] - 2026-11-20

### Changed
- **Antigravity-first discovery**: `scripts/install.sh` now syncs **all** kit skills into `.agents/skills/` so Antigravity discovers them natively.
- Default `--ides` changed to `none` (clean `.agents/`-only setup for Antigravity), while preserving `--ides claude,cursor,windsurf` or `--ides all` for multi-IDE compatibility.
- Updated `post-implementation-testing.md` and `implement-spec-tasks/SKILL.md` to reference Antigravity `browser` subagent / Playwright MCP alongside headless Playwright scripts.

## [1.0.0] - 2026-11-20

### Added
- Initial extraction of the Spec-Driven Agent Harness from `secret-santa`.
