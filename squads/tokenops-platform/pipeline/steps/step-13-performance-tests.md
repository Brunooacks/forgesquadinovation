---
step: "13"
name: "Testes de Performance — Gateway Proxy & Analytics Pipeline"
type: agent
agent: qa-engineer
tasks:
  - performance-test
depends_on: step-12
phase: quality
---

# Step 13: Testes de Performance — Gateway Proxy & Analytics Pipeline

## Para o Pipeline Runner

O QA Engineer executa testes de performance focados nos componentes criticos do TokenOps: o Gateway Proxy (path critico de latencia) e o Analytics Pipeline (throughput de escrita no ClickHouse). O Pipeline Runner deve invocar o agente qa-engineer com a task performance-test e garantir que os budgets de performance definidos nos NFRs sejam validados.

### Cenarios de performance:

1. **Gateway Proxy — Latencia**:
   - Medir overhead do proxy (target: <50ms adicionais sobre a latencia do LLM provider)
   - Latencia P50, P95, P99 com carga constante
   - Latencia sob carga progressiva (ramp-up de 100 a 10.000 req/s)
   - Impacto do middleware de autenticacao, logging e rate limiting na latencia

2. **Gateway Proxy — Throughput**:
   - Throughput maximo sustentavel (target: 10.000+ req/s)
   - Comportamento sob carga de pico (burst de 2x o throughput nominal)
   - Concorrencia: requests simultaneos por tenant
   - Connection pooling e reutilizacao de conexoes com LLM providers

3. **ClickHouse Analytics Pipeline — Write Throughput**:
   - Volume de escrita sustentavel (events/segundo)
   - Latencia de escrita assincrona (event -> ClickHouse)
   - Batch insert performance vs single insert
   - Impacto de queries concorrentes na escrita

4. **Redis Cache — Hit Ratio e Latencia**:
   - Cache hit ratio para Token Estimator (target: >90% para prompts repetidos)
   - Cache hit ratio para Model Recommendation (target: >85%)
   - Latencia de leitura/escrita do cache (target: <5ms)
   - Comportamento com cache cheio (eviction policy)

5. **Token Estimator — Response Time**:
   - Tempo de resposta para estimativa simples (target: <100ms)
   - Tempo de resposta com comparacao multi-modelo (target: <500ms)
   - Performance dos tokenizers por provider

6. **Dashboard — Page Load Time**:
   - Tempo de carregamento inicial (target: <2s)
   - Tempo de resposta de queries analytics (target: <3s para periodos de 30 dias)
   - Performance com alto volume de dados (100k+ requests no periodo)

### Ferramentas:
- k6 ou Artillery para testes de carga HTTP
- Custom scripts para pipeline ClickHouse
- Lighthouse ou Web Vitals para frontend performance

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Test strategy | `output/quality/test-strategy.md` | Estrategia de testes com budgets de performance |
| NFRs | `output/requirements/project-brief.md` | Requisitos nao-funcionais com valores alvo |
| Test report | `output/quality/test-report.md` | Resultados dos testes automatizados do step-12 |
| Architecture doc | `output/architecture/architecture-document.md` | Arquitetura com decisoes de performance |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Performance Report | `output/quality/performance-report.md` | Relatorio completo de performance com metricas, graficos e recomendacoes |

### Estrutura do performance-report.md

```
# TokenOps Platform — Performance Test Report
## 1. Resumo Executivo
## 2. Ambiente de Testes
## 3. Gateway Proxy — Latencia
### 3.1 Resultados (P50, P95, P99)
### 3.2 Overhead vs Budget (<50ms)
## 4. Gateway Proxy — Throughput
### 4.1 Throughput Sustentavel vs Budget (10k+ req/s)
### 4.2 Comportamento sob Carga de Pico
## 5. ClickHouse Analytics Pipeline
### 5.1 Write Throughput
### 5.2 Latencia de Escrita Assincrona
## 6. Redis Cache
### 6.1 Hit Ratio
### 6.2 Latencia de Cache
## 7. Token Estimator — Response Time
## 8. Dashboard — Page Load Time
## 9. Bottlenecks Identificados
## 10. Recomendacoes de Otimizacao
```

## Execution Mode

- **Tipo**: Agent (automatizado)
- **Agente**: qa-engineer
- **Tasks**: performance-test
- **Automatizavel**: Sim — execucao pelo agente com ferramentas de carga
- **Tempo estimado**: 2-4 horas de execucao

## Quality Gate

- [ ] Gateway proxy overhead < 50ms (P95)
- [ ] Gateway throughput >= 10.000 req/s sustentavel
- [ ] ClickHouse write pipeline funcional e assincrono
- [ ] Redis cache hit ratio > 85% para estimativas e recomendacoes
- [ ] Token Estimator response time < 100ms (P95)
- [ ] Dashboard page load < 2s
- [ ] Nenhum memory leak ou degradacao progressiva identificada
- [ ] Relatorio performance-report.md gerado com todas as metricas
