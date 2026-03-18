---
step: "12"
name: "Testes Automatizados — Estimacao de Tokens, Proxy, Recomendacao"
type: agent
agent: qa-engineer
tasks:
  - write-test-cases
  - automate-tests
  - run-regression
depends_on: step-11
phase: quality
---

# Step 12: QA Engineer — Testes Automatizados TokenOps

## Para o Pipeline Runner

Acione o agente `qa-engineer` com as tasks `write-test-cases`, `automate-tests`
e `run-regression`. O QA deve escrever e executar testes de integracao, E2E e
testes de precisao especificos para o TokenOps, validando Token Estimation accuracy,
Gateway proxy behavior e Model Recommendation quality.

### Instrucoes para o Agente:

1. **Leia** a estrategia de testes, criterios de aceitacao e codigo implementado.

2. **Escreva** testes de integracao:
   - **Gateway <-> LLM Providers:**
     - Request proxying para cada provider (OpenAI, Anthropic, Google, Bedrock, Azure).
     - Streaming responses (SSE).
     - Error handling (provider down, rate limited, invalid API key).
     - Circuit breaker activation e recovery.
   - **Gateway <-> ClickHouse:**
     - Event logging (request, tokens, cost).
     - Dados corretos no ClickHouse apos request.
   - **Gateway <-> Redis:**
     - Rate limiting enforcement.
     - Token estimation cache hit/miss.
   - **Dashboard API <-> PostgreSQL:**
     - CRUD de tenants, users, API keys, projetos.
   - **Dashboard API <-> ClickHouse:**
     - Analytics queries (usage by period, cost by model).
     - Filtros e agregacoes.
   - **Multi-tenancy Isolation:**
     - Tenant A nao acessa dados de Tenant B via API.
     - Tenant A nao acessa dados de Tenant B via Dashboard.
     - Rate limits sao por tenant.

3. **Escreva** testes E2E:
   - **Happy path completo:** Login -> Enviar request via Gateway -> Ver metricas no Dashboard.
   - **Token Estimation:** Estimar tokens -> Enviar request -> Comparar estimativa vs. real.
   - **Model Recommendation:** Solicitar recomendacao -> Enviar com modelo sugerido -> Verificar custo.
   - **Cost Explorer:** Filtrar custos por periodo/modelo -> Exportar CSV.
   - **API Key Management:** Criar key -> Usar no Gateway -> Revogar -> Confirmar bloqueio.
   - **Fluxos de erro:** Provider down -> Circuit breaker -> Fallback.

4. **Escreva** testes de precisao:
   - **Token Estimation Benchmark:**
     - Dataset de 100+ prompts de diferentes tamanhos e complexidades.
     - Comparacao: estimated_tokens vs. actual_tokens (retornados pelo provider).
     - Meta: > 95% accuracy (margem de erro < 5%).
     - Breakdown por modelo (GPT-4, Claude, Gemini, etc.).
   - **Cost Calculation Precision:**
     - Verificar calculo de custo contra pricing tables oficiais.
     - Margem de erro aceitavel: < $0.001 por request.
   - **Model Recommendation Quality:**
     - Benchmark: modelo recomendado vs. modelo mais barato vs. modelo mais caro.
     - Verificar que recomendacao reduz custo em pelo menos X% sem perda de qualidade.

5. **Automatize** os testes:
   - Configure Jest para testes de integracao com containers (testcontainers).
   - Configure Playwright/Cypress para E2E.
   - Configure benchmark suite para testes de precisao.
   - Integre com GitHub Actions.

6. **Execute** a suite de regressao:
   - Rode todos os testes (unitarios + integracao + E2E + precisao).
   - Colete metricas de cobertura.
   - Identifique testes flaky e estabilize.
   - Gere relatorio consolidado.

### Regras:

- Cada criterio de aceitacao deve ter pelo menos 1 teste automatizado.
- Testes E2E devem cobrir 100% dos fluxos criticos.
- Token Estimation accuracy test deve usar dataset diversificado.
- Testes devem ser deterministicos (mocked LLM responses para testes deterministicos).
- Dados de teste devem ser isolados entre execucoes.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Strategy | `output/planning/test-strategy.md` | Estrategia e metas de cobertura |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Base para casos de teste |
| Backend Code | `output/implementation/backend/` | Codigo NestJS para testar |
| Frontend Code | `output/implementation/frontend/` | Codigo Next.js para testar |
| Architecture Design | `output/architecture/architecture-design.md` | Contratos de API |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Cases | `output/quality/test-cases/` | Casos de teste documentados |
| Test Code | `output/quality/automated-tests/` | Codigo dos testes automatizados |
| Test Report | `output/quality/test-report.md` | Relatorio consolidado de testes |

### Estrutura do test-report.md:

```markdown
# Relatorio de Testes — TokenOps

## Resumo Executivo
- **Total de testes:** [N]
- **Passaram:** [N] ([X%])
- **Falharam:** [N] ([X%])
- **Ignorados:** [N]
- **Tempo de execucao:** [X minutos]

## Cobertura
| Metrica | Meta | Alcancado | Status |
|---------|------|-----------|--------|
| Cobertura de codigo | 80% | [X%] | OK/NOK |
| Cobertura de branches | 70% | [X%] | OK/NOK |
| Fluxos criticos | 100% | [X%] | OK/NOK |

## Token Estimation Accuracy
| Modelo | Prompts Testados | Accuracy | Meta | Status |
|--------|-----------------|----------|------|--------|
| GPT-4 | [N] | [X%] | 95% | OK/NOK |
| Claude | [N] | [X%] | 95% | OK/NOK |
| Gemini | [N] | [X%] | 95% | OK/NOK |

## Cost Calculation Precision
| Cenario | Desvio Maximo | Meta | Status |
|---------|--------------|------|--------|
| Single request | $[X] | <$0.001 | OK/NOK |
| Batch aggregate | $[X] | <$0.01 | OK/NOK |

## Multi-tenancy Isolation
| Teste | Resultado |
|-------|-----------|
| API data isolation | PASS/FAIL |
| Dashboard data isolation | PASS/FAIL |
| Rate limit isolation | PASS/FAIL |

## Bugs Encontrados
| ID | Descricao | Severidade | Modulo | Status |
|----|-----------|-----------|--------|--------|
| BUG-001 | [Descricao] | Critico | Gateway | Aberto |

## Riscos e Recomendacoes
[Lista de riscos identificados]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `qa-engineer`
- **Skills:** `write-test-cases`, `automate-tests`, `run-regression`
- **Timeout:** 60 minutos
- **Retries:** 2

## Quality Gate

Antes de avancar para o Step 13, verifique:

- [ ] Todos os criterios de aceitacao cobertos por testes
- [ ] Testes E2E para 100% dos fluxos criticos
- [ ] Token Estimation accuracy > 95% (ou justificativa)
- [ ] Cost calculation precision < $0.001/request
- [ ] Multi-tenancy isolation validada
- [ ] Cobertura de codigo dentro da meta
- [ ] Nenhum teste flaky na suite
- [ ] Relatorio de testes gerado
- [ ] Bugs criticos documentados
- [ ] Suite de regressao integrada com CI/CD
