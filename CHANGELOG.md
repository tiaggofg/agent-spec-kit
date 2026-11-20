# Changelog

## [1.0.0] - 2026-11-20

### Added
- Initial extraction of the Spec-Driven Agent Harness from `secret-santa`.
- Managed rules in `core/.agents/rules/`:
  - `post-implementation-testing.md`
  - `spec-handoff-only.md`
  - `post-cycle-approval-and-docs.md`
- Managed skills in `core/.agents/skills/`:
  - `implement-spec-tasks` (project-agnostic 5-stage runbook)
  - `grill-me`, `grilling`
- Multi-IDE skills in `core/skills/` (synced to `.claude/`, `.cursor/`, `.windsurf/`):
  - `tlc-spec-driven`, `domain-analysis`, `tactical-ddd`, `the-judge`, `frontend-design`, `web-design-guidelines`, `figma-implement-design`
- Project templates (`templates/AGENTS.md`, `templates/.specs/STATE.md`) created only when missing.
- `scripts/install.sh` and generated `.agents/update-spec-kit.sh` for idempotent installation and updates without clobbering project files.
- `scripts/validate-kit.sh` for kit integrity validation.
