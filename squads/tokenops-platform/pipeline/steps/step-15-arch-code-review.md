---
step: "15"
name: "Revisao Arquitetural do Codigo"
type: agent
agent: architect
tasks:
  - review-architecture
depends_on: step-14
phase: review
---

# Step 15: Revisao Arquitetural do Codigo

## Para o Pipeline Runner

O Architect executa uma revisao arquitetural do codigo implementado para garantir que a implementacao esta aderente ao design definido nos steps de arquitetura. O Pipeline Runner deve invocar o agente architect com a task review-architecture. Esta revisao complementa o code review do Tech Lead (step-14) com foco em decisoes arquiteturais de alto nivel.

### Checklist de revisao arquitetural:

1. **Arquitetura Modular — Bounded Contexts**:
   - Modulos Gateway, Estimator, Recommender e Dashboard com boundaries claros
   - Sem acoplamento direto entre modulos (comunicacao via interfaces ou eventos)
   - Cada modulo com seu proprio conjunto de DTOs, services e repositories
   - Shared kernel minimo e bem definido

2. **Dual-DB Strategy (PostgreSQL + ClickHouse)**:
   - PostgreSQL para dados transacionais (tenants, API keys, configuracoes, users)
   - ClickHouse para dados analiticos (request logs, token usage, cost analytics)
   - Sem queries analiticas no PostgreSQL
   - Sem escritas transacionais no ClickHouse
   - Migracoes separadas para cada banco

3. **Adapter Pattern para LLM Providers**:
   - Interface LLMAdapter uniforme e bem definida
   - Cada provider (OpenAI, Anthropic, Gemini, Azure, Bedrock, Groq, DeepSeek) com adapter dedicado
   - Factory/Registry para resolucao de adapter por provider
   - Nenhuma dependencia direta de SDKs de providers fora dos adapters
   - Facilidade de adicionar novos providers sem alterar codigo existente

4. **Event-Driven Analytics (Async Writes)**:
   - Escritas no ClickHouse feitas de forma assincrona (nao bloqueiam o request path)
   - Event bus ou queue (Redis) para desacoplamento
   - Batch writes para otimizar throughput no ClickHouse
   - Garantia de entrega (at-least-once) para eventos analiticos
   - Nao impactar latencia do Gateway proxy

5. **Caching Strategy (Redis)**:
   - Cache de estimativas de tokens (Token Estimator)
   - Cache de recomendacoes de modelos (Recommender)
   - Cache de configuracoes de tenant (API keys, limites)
   - TTL apropriado por tipo de dado
   - Cache invalidation strategy definida
   - Graceful degradation quando Redis indisponivel

6. **Multi-Tenancy Isolation**:
   - Isolamento de dados por tenant em todos os modulos
   - Tenant context propagado em toda a request chain
   - Rate limiting por tenant
   - Sem possibilidade de cross-tenant data leaks
   - Tenant-aware logging e monitoring

7. **NFRs — Conformidade**:
   - Latencia do Gateway proxy < 50ms overhead (validado no step-13)
   - Throughput >= 10.000 req/s (validado no step-13)
   - Disponibilidade: health checks, graceful shutdown, retry logic
   - Observabilidade: structured logging, metrics, tracing

8. **Architectural Drift**:
   - Comparar implementacao com architecture-document.md
   - Identificar desvios e avaliar se sao justificados
   - Documentar ADRs para decisoes que divergem do design original

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Architecture document | `output/architecture/architecture-document.md` | Documento de arquitetura de referencia |
| API contracts | `output/architecture/api-contracts.md` | Contratos de API definidos |
| Database schema | `output/architecture/database-schema.md` | Schemas de banco definidos |
| Backend source code | `output/implementation/` | Codigo-fonte dos modulos backend |
| Frontend source code | `output/implementation/` | Codigo-fonte das paginas frontend |
| Code review report | `output/review/code-review-report.md` | Resultado do code review do Tech Lead |
| Performance report | `output/quality/performance-report.md` | Resultados de performance |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Architectural Review Report | `output/review/arch-review-report.md` | Relatorio de revisao arquitetural com compliance, desvios e ADRs |

### Estrutura do arch-review-report.md

```
# TokenOps Platform — Architectural Review Report
## 1. Resumo Executivo
## 2. Compliance por Principio Arquitetural
### 2.1 Arquitetura Modular (Bounded Contexts)
### 2.2 Dual-DB Strategy
### 2.3 Adapter Pattern
### 2.4 Event-Driven Analytics
### 2.5 Caching Strategy
### 2.6 Multi-Tenancy Isolation
## 3. NFRs — Conformidade
## 4. Architectural Drift
### 4.1 Desvios Identificados
### 4.2 Justificativas
## 5. ADRs Adicionais
## 6. Recomendacoes
## 7. Decisao: Conforme / Nao-Conforme
```

## Execution Mode

- **Tipo**: Agent (automatizado)
- **Agente**: architect
- **Tasks**: review-architecture
- **Automatizavel**: Sim — execucao pelo agente com checklist definido
- **Tempo estimado**: 2-3 horas de revisao

## Quality Gate

- [ ] Bounded contexts respeitados (sem acoplamento direto entre modulos)
- [ ] Dual-DB strategy implementada corretamente (PostgreSQL transacional, ClickHouse analitico)
- [ ] Adapter pattern para todos os 7 LLM providers sem chamadas diretas
- [ ] Analytics writes asincronos (nao bloqueiam Gateway proxy)
- [ ] Caching strategy com Redis implementada e funcional
- [ ] Multi-tenancy isolation validada (sem cross-tenant leaks)
- [ ] NFRs de latencia e throughput atendidos
- [ ] Sem architectural drift critico (ou desvios justificados com ADRs)
- [ ] Relatorio arch-review-report.md gerado com decisao final
