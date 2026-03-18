---
step: "13"
name: "Testes de Performance — Gateway Proxy & Analytics Pipeline"
type: agent
agent: qa-engineer
tasks:
  - performance-test
depends_on: step-12
phase: quality
optional: true
---

# Step 13: QA Engineer — Testes de Performance TokenOps (Opcional)

## Para o Pipeline Runner

Acione o agente `qa-engineer` com a task `performance-test`. Para o TokenOps,
este step e ALTAMENTE RECOMENDADO pois o Gateway proxy e um componente critico
de performance — cada milissegundo de overhead impacta todas as chamadas LLM
dos clientes.

### Condicoes para Execucao:

- O TokenOps TEM requisitos de performance explicitos (latencia proxy, throughput).
- O AI Gateway e um componente de alta carga no caminho critico.
- Este step DEVE ser executado a menos que o usuario explicitamente pule.

### Instrucoes para o Agente:

1. **Leia** os requisitos nao-funcionais e a estrategia de testes.
2. **Configure** o ambiente de testes de performance:
   - Ambiente isolado com PostgreSQL, ClickHouse, Redis.
   - Mock LLM providers com latencia simulada (configuravel).
   - Monitoramento de recursos ativo (CPU, memoria, rede, conexoes).

3. **Execute** cenarios de teste para o AI Gateway Proxy:

   **a) Latency Test (overhead do proxy):**
   - Meca o overhead adicionado pelo Gateway (request -> proxy -> mock LLM -> response).
   - Target: < 50ms overhead no p99.
   - Breakdown: token counting time, routing time, logging time.

   **b) Load Test (carga esperada):**
   - Simule carga de producao esperada.
   - Target: > 1000 requests/segundo (baseline).
   - Meca: throughput, error rate, latency percentiles.

   **c) Stress Test (alem do esperado):**
   - Aumente carga progressivamente ate ponto de ruptura.
   - Identifique o limite de capacidade.
   - Verifique comportamento de degradacao (graceful degradation).

   **d) Circuit Breaker Test:**
   - Simule falha de um provider LLM.
   - Verifique ativacao do circuit breaker.
   - Meca tempo de failover para provider alternativo.
   - Verifique recovery apos provider voltar.

   **e) Rate Limiting Test:**
   - Verifique que rate limiting funciona corretamente por tenant.
   - Meca overhead do rate limiting no hot path.

4. **Execute** cenarios de teste para Analytics Pipeline:

   **a) Ingestao ClickHouse:**
   - Volume de eventos por segundo que o pipeline suporta.
   - Latencia de ingestao (event -> disponivel para query).

   **b) Query Performance:**
   - Dashboard overview query com 1M+ registros.
   - Usage by period com filtros complexos.
   - Cost by model com agregacoes.
   - Target: < 2s para queries do dashboard.

5. **Execute** cenarios para o Dashboard (Frontend):
   - Page load time para paginas principais.
   - Time to interactive com datasets grandes.
   - Core Web Vitals (LCP, FID, CLS).

6. **Analise** resultados e recomende otimizacoes:
   - Gargalos identificados no Gateway (serialization, tokenization, etc.).
   - Otimizacoes de ClickHouse queries (materialized views, indices).
   - Connection pool tuning (Redis, PostgreSQL).
   - Cache strategies para Token Estimation.

### Ferramentas Recomendadas:

- k6 para testes de carga do Gateway.
- Artillery para cenarios complexos com streaming.
- Grafana + Prometheus para monitoramento durante testes.
- Lighthouse para Core Web Vitals.

### Regras:

- Testes de performance devem ser executados em ambiente isolado.
- Usar mock LLM providers (nao enviar requests reais durante load test).
- Resultados devem ser comparaveis entre execucoes (baseline documentado).
- Gargalos criticos no Gateway devem ser reportados com prioridade maxima.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Strategy | `output/planning/test-strategy.md` | Thresholds de performance |
| Architecture Design | `output/architecture/architecture-design.md` | Componentes criticos |
| Backend Code | `output/implementation/backend/` | Gateway e APIs a serem testados |
| Frontend Code | `output/implementation/frontend/` | Dashboard para Core Web Vitals |
| Project Brief | `output/requirements/project-brief.md` | SLAs e requisitos nao-funcionais |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Performance Report | `output/quality/performance-report.md` | Relatorio detalhado de performance |
| Test Scripts | `output/quality/performance-tests/` | Scripts de teste de carga k6/Artillery |

### Estrutura do performance-report.md:

```markdown
# Relatorio de Performance — TokenOps

## Resumo Executivo
- **Status geral:** APROVADO / REPROVADO
- **Gateway overhead p99:** [X]ms (target: <50ms)
- **Gateway throughput:** [X] req/s (target: >1000)
- **Gargalos encontrados:** [N]
- **Otimizacoes recomendadas:** [N]

## AI Gateway Proxy

### Latency Overhead
| Metrica | Target | Resultado | Status |
|---------|--------|-----------|--------|
| p50 overhead | <10ms | [X]ms | OK/NOK |
| p95 overhead | <30ms | [X]ms | OK/NOK |
| p99 overhead | <50ms | [X]ms | OK/NOK |

### Breakdown de Latencia
| Componente | Tempo Medio |
|-----------|-------------|
| Token counting | [X]ms |
| Routing decision | [X]ms |
| Rate limit check | [X]ms |
| Async logging | [X]ms |

### Load Test
| Metrica | Target | Resultado | Status |
|---------|--------|-----------|--------|
| Throughput | >1000 rps | [X] rps | OK/NOK |
| Error Rate | <0.1% | [X%] | OK/NOK |
| p95 Response Time | <500ms | [X]ms | OK/NOK |

### Stress Test
- Ponto de ruptura: [X] req/s
- Comportamento de degradacao: [descricao]

### Circuit Breaker
- Tempo de deteccao de falha: [X]ms
- Tempo de failover: [X]ms
- Tempo de recovery: [X]s

## Analytics Pipeline (ClickHouse)

### Ingestao
| Metrica | Target | Resultado | Status |
|---------|--------|-----------|--------|
| Events/segundo | >5000 | [X] | OK/NOK |
| Latencia ingestao | <5s | [X]s | OK/NOK |

### Query Performance
| Query | Target | Resultado | Status |
|-------|--------|-----------|--------|
| Dashboard overview | <2s | [X]s | OK/NOK |
| Usage by period | <2s | [X]s | OK/NOK |
| Cost by model | <2s | [X]s | OK/NOK |

## Dashboard (Core Web Vitals)
| Metrica | Target | Resultado | Status |
|---------|--------|-----------|--------|
| LCP | <2.5s | [X]s | OK/NOK |
| FID | <100ms | [X]ms | OK/NOK |
| CLS | <0.1 | [X] | OK/NOK |

## Gargalos Identificados
[Lista com evidencias e impacto]

## Recomendacoes de Otimizacao
[Lista priorizada com impacto esperado]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `qa-engineer`
- **Skills:** `performance-test`
- **Timeout:** 60 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 14, verifique:

- [ ] Gateway latency overhead < 50ms no p99
- [ ] Gateway throughput > 1000 req/s
- [ ] Circuit breaker funcional com failover < 100ms
- [ ] ClickHouse queries do dashboard < 2s
- [ ] Core Web Vitals do Dashboard dentro dos targets
- [ ] Gargalos documentados com recomendacoes
- [ ] Scripts de performance versionados para reexecucao
- [ ] Relatorio de performance gerado
