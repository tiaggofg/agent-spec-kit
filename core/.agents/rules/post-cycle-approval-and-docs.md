---
trigger: always_on
---

# Regra de Aprovação, Documentação e Commit/Push Pós-Ciclo

Ao finalizar qualquer ciclo completo de implementação, refatoração ou alteração de infraestrutura/CI/CD:

## 1. Sincronização Obrigatória da Documentação
Antes de solicitar aprovação ou realizar qualquer `git push`, revise e atualize o `README.md` e a documentação técnica em `docs/` (se existir no projeto) para manter a documentação 100% sincronizada com o código:
- **Arquitetura e Dados**: atualize diagramas, entidades, modelos, índices e máquinas de estado caso haja novos componentes, campos ou coleções/tabelas.
- **Fluxos e Regras de Negócio**: atualize fluxogramas, sequências e descrições de algoritmos/regras caso fluxos de UI ou regras tenham mudado.
- **Contratos de API e Segurança**: atualize endpoints, DTOs, status HTTP e políticas de autenticação/privacidade quando alterados.
- **Setup e Deploy**: atualize instruções de execução local, variáveis de ambiente, Docker/Compose ou workflows de CI/CD quando alterados.

## 2. Padrão Obrigatório de Mensagem de Commit (Angular Conventional Commits)
Todo commit **DEVE** seguir o padrão **Conventional Commits (Angular)**:
- **Título (linha 1)**: `<type>(<escopo opcional>): <descrição curta>` com **no máximo 60 caracteres**.
  - Tipos permitidos: `feat`, `fix`, `build`, `ci`, `docs`, `perf`, `refactor`, `style`, `test`, `chore`, `revert`.
- **Corpo (a partir da linha 3, após linha em branco)**: **obrigatório**, descrevendo de forma objetiva o que foi alterado e o porquê.
- Valide antes de commitar com:
  ```bash
  .agents/scripts/validate-commit-msg.sh --message "<título>\n\n<body...>"
  ```

## 3. Aprovação Explícita Antes de Commit e Push
- **Solicitação de Aprovação**: Apresente um resumo objetivo do que foi implementado e dos resultados reais observados nos testes/verificações e **pergunte explicitamente ao usuário se as alterações estão aprovadas**.
- **Sem Commit/Push Antes da Aprovação**: Nunca execute `git commit` ou `git push` antes de receber a aprovação explícita do usuário para o ciclo concluído (salvo quando o usuário já tiver autorizado explicitamente na sessão).
- **Commit e Push Após Aprovação**: Após confirmação, realize `git add`, `git commit` (seguindo o padrão acima) e `git push` para o repositório remoto, incluindo as atualizações de `README.md`, `docs/` e `.specs/`.
