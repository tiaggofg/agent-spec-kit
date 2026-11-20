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

## 2. Aprovação Explícita Antes de Commit e Push
- **Solicitação de Aprovação**: Apresente um resumo objetivo do que foi implementado e dos resultados reais observados nos testes/verificações e **pergunte explicitamente ao usuário se as alterações estão aprovadas**.
- **Sem Commit/Push Antes da Aprovação**: Nunca execute `git commit` ou `git push` antes de receber a aprovação explícita do usuário para o ciclo concluído (salvo quando o usuário já tiver autorizado explicitamente na sessão).
- **Commit e Push Após Aprovação**: Após confirmação, realize `git add`, `git commit` (seguindo Conventional Commits) e `git push` para o repositório remoto, incluindo as atualizações de `README.md`, `docs/` e `.specs/`.
