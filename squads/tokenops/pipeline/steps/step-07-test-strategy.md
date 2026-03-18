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

# Step 07: QA Engineer — Definicao de Estrategia de Testes TokenOps

## Para o Pipeline Runner

Acione o agente `qa-engineer` com a task `define-test-strategy`. O QA Engineer
deve definir a estrategia completa de testes para o TokenOps, com atencao especial
a precisao do Token Estimation Engine, performance do Gateway proxy, qualidade
das recomendacoes de modelo e integracao com multiplos LLM providers.

### Instrucoes para o Agente:

1. **Leia** os requisitos, criterios de aceitacao e arquitetura.
2. **Defina** a piramide de testes para TokenOps:

   **Testes Unitarios:**
   - Token Estimation Engine: precisao por modelo, edge cases (empty prompt, max tokens)
   - Cost Engine: calculo de custos, pricing tables, conversao de moeda
   - Model Recommendation: algoritmo de ranking, scoring
   - Gateway: request parsing, routing logic, rate limiting logic
   - Dashboard API: filtros, agregacoes, paginacao

   **Testes de Integracao:**
   - Gateway <-> LLM Providers (OpenAI, Anthropic, Google, Bedrock, Azure)
   - Gateway <-> ClickHouse (event logging)
   - Gateway <-> Redis (rate limiting, caching)
   - Dashboard API <-> PostgreSQL
   - Dashboard API <-> ClickHouse (analytics queries)
   - Multi-tenancy isolation (tenant A nao ve dados de tenant B)

   **Testes E2E:**
   - Fluxo completo: request -> Gateway -> LLM -> response + logging + cost calculation
   - Token estimation -> envio -> comparacao com tokens reais
   - Model recommendation -> envio com modelo sugerido -> validacao custo
   - Dashboard: login -> visualizar metricas -> filtrar -> exportar

   **Testes de Performance:**
   - Gateway proxy latency overhead (target: < 50ms p99)
   - Gateway throughput (target: > 1000 req/s)
   - ClickHouse query performance para analytics
   - Dashboard page load times

   **Testes de Precisao/Qualidade:**
   - Token Estimation accuracy (target: > 95% accuracy vs. real tokens)
   - Model Recommendation quality (custo efetivo vs. benchmark)
   - Cost calculation precision (centavos de diferenca)

3. **Selecione** ferramentas e frameworks:
   - Jest para testes unitarios e integracao (NestJS)
   - Cypress ou Playwright para E2E
   - k6 para testes de performance do Gateway
   - Custom benchmark suite para Token Estimation accuracy
4. **Defina** metas de cobertura.
5. **Planeje** a automacao e integracao com CI/CD.
6. **Defina** estrategia de dados de teste (mock LLM responses, fixtures de tokens).

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | Requisitos para cobertura |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Base para casos de teste |
| Architecture Design | `output/architecture/architecture-design.md` | Componentes a testar |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Tarefas planejadas |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Strategy | `output/planning/test-strategy.md` | Estrategia completa de testes TokenOps |

### Estrutura do test-strategy.md:

```markdown
# Estrategia de Testes — TokenOps

## 1. Piramide de Testes
### 1.1 Testes Unitarios
- Cobertura minima: 80%
- Ferramentas: Jest + ts-jest
- Foco: Token Estimation accuracy, Cost Engine precision, Routing logic

### 1.2 Testes de Integracao
- Gateway <-> LLM Providers (mocked + real com sandbox)
- Multi-tenancy isolation
- ClickHouse event pipeline

### 1.3 Testes E2E
- Fluxos criticos do Gateway
- Fluxos do Dashboard

### 1.4 Testes de Performance
- Gateway latency & throughput
- ClickHouse analytics queries
- Dashboard page load

### 1.5 Testes de Precisao
- Token Estimation accuracy benchmark
- Model Recommendation quality scoring
- Cost calculation precision

## 2. Metas de Cobertura
| Metrica | Meta | Minimo |
|---------|------|--------|
| Cobertura de codigo | 80% | 70% |
| Token Estimation accuracy | 95% | 90% |
| Gateway latency overhead | <50ms p99 | <100ms p99 |
| Gateway throughput | >1000 req/s | >500 req/s |

## 3. Ferramentas e Frameworks
## 4. Automacao e CI/CD
## 5. Dados de Teste (mock LLM responses)
## 6. Criterios de Aprovacao
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `qa-engineer`
- **Skills:** `define-test-strategy`
- **Timeout:** 20 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 08, verifique:

- [ ] Todos os niveis da piramide de testes definidos
- [ ] Testes de precisao para Token Estimation definidos
- [ ] Testes de performance para Gateway proxy definidos
- [ ] Testes de multi-tenancy isolation definidos
- [ ] Ferramentas selecionadas para cada nivel
- [ ] Metas de cobertura estabelecidas (codigo + precisao + performance)
- [ ] Estrategia de mock para LLM providers definida
- [ ] Integracao com CI/CD (GitHub Actions) planejada
