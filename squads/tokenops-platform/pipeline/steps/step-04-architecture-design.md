---
step: "04"
name: "Design de Arquitetura — AI Gateway, Dual-DB, LLM Adapters"
type: agent
agent: architect
tasks:
  - design-architecture
  - create-adr
depends_on: step-03
phase: architecture
---

# Step 04: Design de Arquitetura — AI Gateway, Dual-DB, LLM Adapters

## Para o Pipeline Runner

O agente Architect deve projetar a arquitetura completa do TokenOps Platform, tomando decisoes fundamentais sobre o proxy gateway, estrategia de banco de dados dual, adapter pattern para LLMs e pipeline de analytics. Cada decisao maior deve ser documentada como um ADR (Architecture Decision Record).

### Decisoes arquiteturais chave:

1. **AI Gateway Proxy Architecture**:
   - Avaliar opcoes: Kong Gateway, Envoy Proxy, custom NestJS proxy
   - Requisitos: interceptacao transparente, token counting pre/post, cost calculation, routing rules, caching
   - Deve suportar protocolos: REST (chat completions, embeddings), streaming (SSE)
   - Latencia overhead target: <50ms
   - Throughput target: 10.000+ req/s

2. **Dual-Database Strategy (OLTP + OLAP)**:
   - PostgreSQL (OLTP): users, organizations, teams, projects, API keys, billing, configurations
   - ClickHouse (OLAP): prompt logs, token usage events, cost calculations, analytics aggregations
   - Estrategia de sincronizacao: event-driven (write to PG + emit event to ClickHouse)
   - Retencao de dados por plano (90d, 1y, 2y)

3. **LLM Adapter Pattern para 7 providers**:
   - Interface unificada: `LLMAdapter` com metodos `complete()`, `stream()`, `embed()`, `estimateTokens()`
   - Adapters: OpenAI, Anthropic, Gemini, Azure OpenAI, AWS Bedrock, Groq, DeepSeek
   - Token counting especifico por provider (tiktoken para OpenAI, contagem nativa para Anthropic, etc.)
   - Pricing tables atualizaveis (config, nao hardcoded)
   - Circuit breaker e fallback entre providers

4. **Redis Caching Strategy**:
   - Response cache (semantic similarity para prompts repetidos)
   - Rate limiting por org/API key
   - Session cache para dashboard real-time
   - Token estimation cache (prompt hash -> estimativa)

5. **Event-Driven Analytics Pipeline**:
   - Cada request ao gateway gera um evento
   - Event bus: Redis Streams ou Bull queues
   - Consumer: processa eventos e insere no ClickHouse
   - Aggregation workers: pre-calcula metricas para dashboard

6. **Microservices vs Modular Monolith**:
   - Avaliar: modular monolith (NestJS modules) para MVP, migrar para microservices se necessario
   - Modulos: GatewayModule, EstimatorModule, RecommenderModule, AnalyticsModule, PlatformModule, DashboardModule

7. **API Design**:
   - REST API para CRUD e gateway proxy
   - WebSocket para dashboard real-time (custo ao vivo, alertas)
   - GraphQL como alternativa futura (V2)
   - API versioning (v1)

### Arquitetura de referencia do PRD:

```
Clients (SDK/API/Extensions)
    |
    v
AI Gateway (Proxy + Token Counter + Cost Calculator)
    |
    v
Optimization Engine (Prompt Opt + Model Recommendation)
    |
    v
LLM Providers (OpenAI, Anthropic, Gemini, Azure, Bedrock, Groq, DeepSeek)
    |
    v
Analytics Engine (Event Pipeline -> ClickHouse -> Dashboard)
```

### ADRs a produzir:

- ADR-001: Gateway proxy technology choice
- ADR-002: Dual-database strategy (PostgreSQL + ClickHouse)
- ADR-003: LLM adapter pattern design
- ADR-004: Caching strategy and invalidation
- ADR-005: Event-driven analytics pipeline
- ADR-006: Modular monolith vs microservices
- ADR-007: API design (REST + WebSocket)
- ADR-008: Multi-tenancy isolation model
- ADR-009: Authentication and API key management

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| User Stories | `output/requirements/user-stories.md` | Stories aprovadas para derivar componentes |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios que influenciam decisoes tecnicas |
| Project Brief | `output/requirements/project-brief.md` | NFRs, tech stack, constraints |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Documento completo de arquitetura |
| ADRs | `output/architecture/adrs/` | Um arquivo por ADR (ADR-001.md a ADR-009.md) |

### Estrutura do architecture-design.md

```
# TokenOps Platform — Architecture Design
## 1. Visao Geral da Arquitetura
## 2. Diagrama de Componentes (C4 Level 2)
## 3. AI Gateway Proxy Design
## 4. Dual-Database Strategy
## 5. LLM Adapter Pattern
## 6. Event-Driven Analytics Pipeline
## 7. Caching Strategy
## 8. API Design (REST + WebSocket)
## 9. Multi-Tenancy Model
## 10. Security Architecture
## 11. Observability (OpenTelemetry + Prometheus + Grafana)
## 12. Deployment Architecture
## 13. Technology Stack Summary
```

### Estrutura de cada ADR

```
# ADR-NNN: [Titulo]
## Status: Proposed
## Context
## Decision
## Alternatives Considered
## Consequences (Positive / Negative)
## References
```

## Execution Mode

- **Tipo**: Agent (architect)
- **Requer input do usuario**: Nao — agente trabalha autonomamente
- **Automatizavel**: Sim
- **Tempo estimado**: 20-35 minutos de execucao do agente

## Quality Gate

- [ ] Todos os 7 componentes arquiteturais documentados
- [ ] ADRs produzidos para cada decisao maior (minimo 9 ADRs)
- [ ] Diagrama de componentes (C4 Level 2) incluido
- [ ] NFRs enderecados (latencia <50ms, throughput 10k+ req/s)
- [ ] Adapter pattern cobre todos os 7 LLM providers
- [ ] Dual-DB strategy com estrategia de sincronizacao clara
- [ ] Multi-tenancy isolation model definido
- [ ] Security architecture (API keys, encryption, RBAC)
- [ ] Observability stack definido (OpenTelemetry + Prometheus + Grafana)
