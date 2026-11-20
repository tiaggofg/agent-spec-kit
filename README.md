# agent-spec-kit

Boilerplate e harness reutilizável para **Spec-Driven Development** focado em **Antigravity** (com compatibilidade opcional para Claude Code, Cursor e Windsurf), extraído e generalizado a partir do projeto `secret-santa`.

Permite instalar rapidamente regras, skills e templates em qualquer projeto pessoal e **atualizar todos os projetos consumidores** a partir deste repositório central sem sobrescrever `AGENTS.md` nem `.specs/` de cada projeto.

---

## O que vem no Kit

### 1. Arquivos Gerenciados (Atualizados a cada sync em `.agents/`)
O Antigravity descobre nativamente `AGENTS.md`, `.agents/rules/*.md` e `.agents/skills/*/SKILL.md`. Por padrão, todas as regras e skills são instaladas em `.agents/` mantendo a raiz do projeto limpa:

- **Regras em `.agents/rules/`** (`trigger: always_on`):
  - `spec-handoff-only.md`: separa a sessão de planejamento (Spec + Tasks + Handoff) da sessão de implementação.
  - `feature-naming-and-quality.md`: exige padrão `[0-9]+-[a-zA-Z][a-zA-Z0-9-]*` nas pastas de `.specs/features/` e análise estática determinística (Lint + SonarQube local).
  - `post-implementation-testing.md`: exige validação prática real após mudanças (Playwright via MCP/subagente `browser`/script para UI/Full-Stack, requests HTTP reais para Backend-only, execução real para CLI).
  - `post-cycle-approval-and-docs.md`: exige sincronização de `README.md` + `docs/` e aprovação explícita do usuário antes de `git commit` e `git push`.
- **Scripts Determinísticos em `.agents/scripts/`**:
  - `validate-feature-name.sh`: valida nomes de pastas em `.specs/features/`.
  - `validate-commit-msg.sh`: valida Angular Conventional Commits (título `<= 60` chars + body obrigatório); instalado também em `.git/hooks/commit-msg` quando o repo ainda não possui esse hook.
  - `quality-check.sh`: roda lint do projeto, executa `sonar-scanner` (local ou via Docker) e consulta deterministicamente o Quality Gate e issues na API do SonarQube local.
- **Skills em `.agents/skills/`**:
  - `implement-spec-tasks`: runbook de 5 etapas para implementar uma feature aprovada a partir de `.specs/features/<feature>/tasks.md`.
  - `tlc-spec-driven`: ciclo Specify → Design → Tasks → Execute + scripts determinísticos de validação.
  - `grill-me` / `grilling`: entrevista estruturada para destrinchar decisões e requisitos antes de codar.
  - `domain-analysis` & `tactical-ddd`: modelagem de domínio e DDD tático.
  - `the-judge`: revisão crítica de código e gate de qualidade.
  - `frontend-design`, `web-design-guidelines`, `figma-implement-design`: design de UI e acessibilidade.

*(Opcional)* Para espelhar também para outros harnesses/IDEs, passe `--ides claude,cursor,windsurf` ou `--ides all`.

### 2. Templates e Ferramentas do Projeto (Criados apenas se não existirem)
- `AGENTS.md`: estrutura base para descrever visão, stack, invariantes e comandos do projeto.
- `.specs/STATE.md`: memória de decisões arquiteturais (`AD-NNN`) e `## Handoff` entre sessões.
- `docs/`: estrutura padrão de documentação viva (Markdown + diagramas Mermaid + `docs/adr/` para Architecture Decision Records):
  - `docs/README.md`, `arquitetura-c4.md`, `modelo-dominio-e-dados.md`, `fluxos-e-sequencias.md`, `api-rest.md`, `seguranca-e-privacidade.md`, `deploy-e-ci-cd.md`
  - `docs/adr/README.md` e `docs/adr/0000-template.md`
- `.sonarqube/docker-compose.yml`: SonarQube local (`lts-community`, porta `9000`) com persistência em named volumes do Docker (`sonarqube_data`, `sonarqube_logs`, `sonarqube_extensions`).
- `sonar-project.properties`: configuração base do projeto para o scanner.
- `.github/workflows/release.yml`, `release-please-config.json`, `.release-please-manifest.json`: automação via **Release Please** para gerar `CHANGELOG.md`, bump de versão e GitHub Release automaticamente a partir dos Conventional Commits. *(No GitHub, habilite `Settings → Actions → General → Allow GitHub Actions to create and approve pull requests`.)*

> **Garantia de atualização segura**: rodar o update **nunca sobrescreve** seu `AGENTS.md`, `.specs/STATE.md`, `.specs/features/*` ou regras/skills customizadas criadas especificamente no projeto consumidor.

---

## Como Instalar em um Projeto Novo ou Existente

Na raiz do projeto destino:

```bash
curl -fsSL https://raw.githubusercontent.com/tiaggofg/agent-spec-kit/main/scripts/install.sh | bash
```

*(Opcional)* **Via Clone Local**:
```bash
/caminho/para/agent-spec-kit/scripts/install.sh --target /caminho/para/seu-projeto
```

### Opções úteis do `install.sh`
- `--ides none|claude,cursor,windsurf|all`: espelha skills também para outros harnesses (padrão: `none`, mantendo apenas `.agents/` para Antigravity).
- `--up-sonar`: já sobe o container do SonarQube local ao final da instalação.
- `--skip-tools`: pula a criação de `.sonarqube/` e `sonar-project.properties`.
- `--ref v1.2.0`: fixa uma tag ou branch específica.
- `--dry-run`: mostra o que seria atualizado sem alterar arquivos.
- `--force-templates`: sobrescreve `AGENTS.md`, `.specs/STATE.md` e `sonar-project.properties` com os templates do kit.

---

## Como Atualizar um Projeto que Já Usa o Kit

Cada projeto instalado recebe:
- `.spec-kit.json` (versão atual, repo, ref e IDEs configuradas)
- `.agents/update-spec-kit.sh` (atalho de atualização)

Sempre que você evoluir uma regra ou skill no `agent-spec-kit` (e fizer push):

```bash
# No projeto consumidor:
./.agents/update-spec-kit.sh
```

Para testar/atualizar a partir de um clone local antes de dar push:

```bash
./.agents/update-spec-kit.sh --local ../agent-spec-kit
```

---

## Fluxo Recomendado no Antigravity

1. **Planejar (`tlc-spec-driven` + `grill-me`)**: discuta requisitos, gere `.specs/features/<feature>/spec.md` e `tasks.md`, aprove a spec e atualize `.specs/STATE.md` (`## Handoff`).
2. **Nova Sessão de Implementação (`implement-spec-tasks`)**: inicie uma nova conversa pedindo para executar as tasks da feature em `.specs/STATE.md`.
3. **Validação Obrigatória**: o agente roda testes automatizados + verificação real (Playwright MCP / subagente `browser` ou HTTP requests) e atualiza `README.md` / `docs/`.
4. **Aprovação e Push**: após sua confirmação explícita, o agente faz `git commit` e `git push`.

---

## Desenvolvimento do Próprio Kit

Para validar a integridade do kit após editar scripts, regras ou skills:

```bash
./scripts/validate-kit.sh
```
