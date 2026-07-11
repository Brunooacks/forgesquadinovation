---
step: "07"
name: "Definicao de Estrategia de Testes"
type: agent
agent: qa-engineer
tasks:
  - define-test-strategy
depends_on: step-06
phase: planning
---

# Step 07: Definicao de Estrategia de Testes

## Para o Pipeline Runner

O agente QA Engineer deve definir a estrategia completa de testes para o TokenOps Platform, cobrindo todos os niveis da piramide de testes e considerando as particularidades do sistema (proxy gateway, multiplos LLM providers, dual-database, real-time dashboard).

### Niveis de teste:

1. **Unit Tests (Jest)**:
   - Cobertura target: 80%+
   - Foco: business logic, token counting algorithms, cost calculation, scoring engine
   - LLM adapters: testar com mocks dos providers
   - Naming convention: `*.spec.ts`
   - Execucao: a cada commit (CI)

2. **Integration Tests (NestJS Testing Module)**:
   - Testar modulos NestJS em isolamento com dependencias reais (DB, Redis)
   - Gateway module: request interception, token counting, cost calculation pipeline
   - Estimator module: estimativa end-to-end com mock LLM
   - Recommender module: scoring algorithm com dados reais
   - Analytics module: event pipeline ate ClickHouse
   - Naming convention: `*.integration-spec.ts`
   - Execucao: a cada PR (CI)

3. **E2E Tests (Playwright)**:
   - Dashboard: navegacao, filtros, graficos renderizam corretamente
   - Token Estimator UI: input prompt, selecionar modelo, ver estimativa
   - Model Recommendation UI: descrever task, ver recomendacoes
   - Settings: criar org, gerar API key, gerenciar equipes
   - Cost Explorer: aplicar filtros, verificar dados
   - Naming convention: `*.e2e-spec.ts`
   - Execucao: antes de cada deploy (CI/CD)

4. **Performance Tests (k6 / Artillery)**:
   - Gateway proxy: latencia p50, p95, p99 sob carga
   - Throughput: validar 10.000+ req/s
   - Dashboard API: response time sob carga de leitura
   - ClickHouse queries: tempo de aggregation queries
   - Cenarios: ramp-up, sustentacao, spike, soak
   - Performance budgets:
     - Gateway proxy overhead: <50ms (p99)
     - Dashboard API: <2s (p95)
     - Token estimation: <100ms (p95)
   - Execucao: semanalmente e antes de releases

5. **Contract Tests (LLM Adapter Interfaces)**:
   - Validar que cada adapter implementa a interface `LLMAdapter` corretamente
   - Testar com stubs dos 7 providers
   - Verificar compatibilidade de request/response formats
   - Detectar breaking changes em APIs dos providers
   - Execucao: a cada PR que toca adapters

### Test Environments:

| Ambiente | Proposito | Dados | LLM Providers |
|----------|-----------|-------|---------------|
| Local (dev) | Desenvolvimento | Seed data + fixtures | Mocks |
| CI | Automacao | Fixtures | Mocks |
| Staging | Pre-producao | Dados sinteticos | Sandbox APIs (quando disponivel) |
| Production | Producao | Dados reais | APIs reais |

### Test Data Strategy:

- **Mock LLM Providers**: Respostas pre-gravadas para cada provider, cobrindo cenarios de sucesso, erro, rate limiting, timeout
- **Fixtures de banco**: Scripts SQL para PostgreSQL e ClickHouse com dados representativos
- **Factories**: Funcoes para gerar dados de teste (prompts, token counts, cost events)
- **Seed data**: Organizacao demo com equipes, projetos e historico de uso

### CI/CD Integration:

```
PR opened:
  -> Unit tests (Jest)
  -> Integration tests (NestJS)
  -> Contract tests (Adapters)
  -> Lint + Type check

PR merged to main:
  -> All above +
  -> E2E tests (Playwright)
  -> Build + Deploy to staging

Release:
  -> All above +
  -> Performance tests (k6)
  -> Smoke tests in staging
  -> Deploy to production
```

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Sprint Backlog | `output/planning/sprint-backlog.md` | Escopo por sprint para alinhar testes |
| Architecture Design | `output/architecture/architecture-design.md` | Componentes a testar |
| User Stories | `output/requirements/user-stories.md` | Acceptance criteria para derivar testes |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Given/When/Then para e2e tests |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Test Strategy | `output/planning/test-strategy.md` | Documento completo da estrategia de testes |

### Estrutura do test-strategy.md

```
# TokenOps Platform — Test Strategy
## 1. Visao Geral e Piramide de Testes
## 2. Unit Tests (Jest)
## 3. Integration Tests (NestJS Testing Module)
## 4. E2E Tests (Playwright)
## 5. Performance Tests (k6/Artillery)
## 6. Contract Tests (LLM Adapters)
## 7. Test Environments
## 8. Test Data Strategy (Mock LLM Providers)
## 9. CI/CD Integration
## 10. Coverage Targets e Metricas
## 11. Performance Budgets
## 12. Defect Management Process
## 13. Tools e Frameworks
```

## Execution Mode

- **Tipo**: Agent (qa-engineer)
- **Requer input do usuario**: Nao — agente trabalha autonomamente
- **Automatizavel**: Sim
- **Tempo estimado**: 10-15 minutos de execucao do agente

## Quality Gate

- [ ] Todos os 5 niveis de teste definidos (unit, integration, e2e, performance, contract)
- [ ] Coverage target de 80%+ para unit tests
- [ ] Performance budgets definidos (proxy <50ms, dashboard <2s, estimation <100ms)
- [ ] Mock strategy para todos os 7 LLM providers
- [ ] CI/CD pipeline de testes documentado
- [ ] Test environments definidos (local, CI, staging, production)
- [ ] Test data strategy com factories e fixtures
- [ ] Contract tests para LLM adapter interfaces
- [ ] Naming conventions definidas para cada nivel
