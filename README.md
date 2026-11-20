# agent-spec-kit

Boilerplate e harness reutilizável para **Spec-Driven Development** com agentes de IA (Antigravity, Claude Code, Cursor, Windsurf), extraído e generalizado a partir do projeto `secret-santa`.

Permite instalar rapidamente regras, skills e templates em qualquer projeto pessoal e **atualizar todos os projetos consumidores** a partir deste repositório central sem sobrescrever `AGENTS.md` nem `.specs/` de cada projeto.

---

## O que vem no Kit

### 1. Arquivos Gerenciados (Atualizados a cada sync)
- **Regras em `.agents/rules/`** (`trigger: always_on`):
  - `spec-handoff-only.md`: separa a sessão de planejamento (Spec + Tasks + Handoff) da sessão de implementação.
  - `post-implementation-testing.md`: exige validação prática real após mudanças (Playwright para UI/Full-Stack, requests HTTP reais para Backend-only, execução real para CLI).
  - `post-cycle-approval-and-docs.md`: exige sincronização de `README.md` + `docs/` e aprovação explícita do usuário antes de `git commit` e `git push`.
- **Skills em `.agents/skills/`**:
  - `implement-spec-tasks`: runbook de 5 etapas para implementar uma feature aprovada a partir de `.specs/features/<feature>/tasks.md`.
  - `grill-me` / `grilling`: entrevista estruturada para destrinchar decisões e requisitos antes de codar.
- **Skills Multi-IDE** (sincronizadas automaticamente para `.claude/skills/`, `.cursor/skills/` e `.windsurf/skills/`):
  - `tlc-spec-driven` (Specify → Design → Tasks → Execute + scripts determinísticos de validação)
  - `domain-analysis`
  - `tactical-ddd`
  - `the-judge`
  - `frontend-design`
  - `web-design-guidelines`
  - `figma-implement-design`

### 2. Templates do Projeto (Criados apenas se não existirem)
- `AGENTS.md`: estrutura base para descrever visão, stack, invariantes e comandos do projeto.
- `.specs/STATE.md`: memória de decisões arquiteturais (`AD-NNN`) e `## Handoff` entre sessões.

> **Garantia de atualização segura**: rodar o update **nunca sobrescreve** seu `AGENTS.md`, `.specs/STATE.md`, `.specs/features/*` ou regras/skills customizadas criadas especificamente no projeto consumidor.

---

## Como Instalar em um Projeto Novo ou Existente

### Opção A — Via Repositório Remoto (GitHub)
Na raiz do projeto destino:

```bash
curl -fsSL https://raw.githubusercontent.com/tiaggofg/agent-spec-kit/main/scripts/install.sh | bash -s -- \
  --repo https://github.com/tiaggofg/agent-spec-kit.git \
  --ref main
```

### Opção B — Via Clone Local
```bash
/caminho/para/agent-spec-kit/scripts/install.sh --target /caminho/para/seu-projeto
```

### Opções úteis do `install.sh`
- `--ides claude,cursor,windsurf`: escolhe quais pastas de IDE recebem as skills (padrão: todas as três).
- `--ref v1.0.0`: fixa uma tag ou branch específica.
- `--dry-run`: mostra o que seria atualizado sem alterar arquivos.
- `--force-templates`: sobrescreve `AGENTS.md` e `.specs/STATE.md` com os templates do kit.

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

## Fluxo Recomendado de Uso

1. **Planejar (`tlc-spec-driven` + `grill-me`)**: discuta requisitos, gere `.specs/features/<feature>/spec.md` e `tasks.md`, aprove a spec e atualize `.specs/STATE.md` (`## Handoff`).
2. **Nova Sessão de Implementação (`implement-spec-tasks`)**: peça ao agente para executar as tasks da feature em `.specs/STATE.md`.
3. **Validação Obrigatória**: o agente roda testes automatizados + verificação real (Playwright ou HTTP requests) e atualiza `README.md` / `docs/`.
4. **Aprovação e Push**: após sua confirmação explícita, o agente faz `git commit` e `git push`.

---

## Desenvolvimento do Próprio Kit

Para validar a integridade do kit após editar scripts, regras ou skills:

```bash
./scripts/validate-kit.sh
```
