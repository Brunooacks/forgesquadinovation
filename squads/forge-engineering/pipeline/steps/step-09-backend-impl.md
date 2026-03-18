---
step: "09"
name: "Implementacao Backend"
type: agent
agent: dev-backend
tasks:
  - implement-api
  - model-database
  - write-unit-tests
depends_on: step-08
phase: implementation
---

# Step 09: Dev Backend — Implementacao Backend

## Para o Pipeline Runner

Acione o agente `dev-backend` com as tasks `implement-api`, `model-database` e
`write-unit-tests`. O desenvolvedor backend deve implementar a camada de servidor
seguindo a arquitetura aprovada e os padroes definidos pelo Arquiteto.

### Instrucoes para o Agente:

1. **Leia** a arquitetura, contratos de API e modelagem de dados.
2. **Configure** o projeto:
   - Estrutura de diretorio conforme arquitetura.
   - Dependencias e configuracao do framework.
   - Configuracao de banco de dados.
   - Variaveis de ambiente.
3. **Implemente** a modelagem de dados:
   - Entidades/modelos conforme diagrama ER.
   - Migrations de banco de dados.
   - Repositories/DAOs.
   - Seeders para dados iniciais.
4. **Implemente** as APIs:
   - Endpoints conforme contratos definidos.
   - Validacao de entrada (request validation).
   - Logica de negocio (services/use cases).
   - Tratamento de erros padronizado.
   - Autenticacao e autorizacao.
5. **Escreva** testes unitarios:
   - Testes para cada service/use case.
   - Testes para validacoes.
   - Testes para tratamento de erros.
   - Mocks para dependencias externas.
6. **Configure** observabilidade:
   - Logging estruturado.
   - Health check endpoint.
   - Metricas basicas.

### Ferramentas Recomendadas:

- **Devin** para implementacao autonoma de features completas.
- **GitHub Copilot** para autocompletar e sugestoes de codigo.
- **StackSpot AI** para aplicar padroes da organizacao.

### Regras:

- Seguir os padroes de codigo definidos na arquitetura.
- Cada endpoint deve ter pelo menos 1 teste unitario.
- Cobertura minima de testes unitarios: conforme test-strategy.md.
- Nenhum segredo hardcoded no codigo.
- Todos os erros devem ter codigos e mensagens padronizados.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Contratos de API, modelagem de dados |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Tarefas de backend atribuidas |
| Test Strategy | `output/planning/test-strategy.md` | Metas de cobertura |
| ADRs | `output/architecture/adrs/` | Decisoes arquiteturais |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Backend Code | `output/implementation/backend/` | Codigo fonte do backend |
| Unit Tests | `output/implementation/backend/tests/` | Testes unitarios |
| Migration Files | `output/implementation/backend/migrations/` | Migrations de banco |
| Backend Report | `output/implementation/backend/implementation-report.md` | Relatorio de implementacao |

## Execution Mode

- **Modo:** Subagent
- **Agente:** `dev-backend`
- **Skills:** `implement-api`, `model-database`, `write-unit-tests`
- **Timeout:** 60 minutos
- **Retries:** 2

## Quality Gate

Antes de avancar para o Step 10, verifique:

- [ ] Todos os endpoints da API implementados
- [ ] Modelagem de dados completa com migrations
- [ ] Testes unitarios passando
- [ ] Cobertura de testes dentro da meta
- [ ] Nenhum segredo hardcoded
- [ ] Logging estruturado configurado
- [ ] Health check endpoint funcional
- [ ] Tratamento de erros padronizado
- [ ] Codigo segue padroes da arquitetura
