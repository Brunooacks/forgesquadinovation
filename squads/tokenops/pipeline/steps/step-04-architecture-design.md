---
step: "04"
name: "Design de Arquitetura — AI Gateway & Plataforma"
type: agent
agent: architect
tasks:
  - design-architecture
  - create-adr
depends_on: step-03
phase: architecture
---

# Step 04: Architect — Design de Arquitetura TokenOps

## Para o Pipeline Runner

Acione o agente `architect` com as tasks `design-architecture` e `create-adr`.
O Arquiteto deve produzir um documento de arquitetura completo para a plataforma
TokenOps, com foco especial no AI Gateway proxy, LLM routing, cost engine e
analytics pipeline.

### Instrucoes para o Agente:

1. **Leia** os requisitos aprovados (`user-stories.md`, `acceptance-criteria.md`).
2. **Leia** o project brief para contexto de restricoes e stack tecnologica.
3. **Defina** o estilo arquitetural:
   - Arquitetura modular monolito com Gateway separado ou microservicos.
   - Justifique a escolha considerando MVP vs. escala futura.
4. **Projete** os componentes principais:
   - **AI Gateway Proxy** — Ponto de entrada para todas as chamadas LLM:
     - Request interception e token counting
     - LLM provider routing (OpenAI, Anthropic, Google, Bedrock, Azure)
     - Load balancing e failover entre providers
     - Rate limiting por tenant/API key
     - Circuit breaker por provider
     - Request/response logging para analytics
   - **Token Estimation Engine** — Motor de estimativa pre-envio:
     - Tokenizer por modelo (tiktoken, etc.)
     - Cache de estimativas
     - Estimativa de custo baseada em pricing tables
   - **Model Recommendation Engine** — Recomendacao inteligente:
     - Ranking custo/qualidade por task type
     - Historico de qualidade por modelo
     - A/B testing de modelos
   - **Cost Engine** — Motor de calculo de custos:
     - Pricing tables por provider/modelo (atualizavel)
     - Calculo em tempo real de custo por request
     - Agregacao por tenant/time/projeto
   - **Analytics Pipeline** — Pipeline de dados:
     - Ingestao de eventos do Gateway
     - Armazenamento em ClickHouse para analytics
     - Agregacoes pre-calculadas para Dashboard
   - **Dashboard API** — APIs para o frontend:
     - Metricas de uso (tokens, requests, custo)
     - Filtros por periodo, modelo, time, projeto
     - Exportacao de dados
   - Diagrama de contexto (C4 Level 1)
   - Diagrama de containers (C4 Level 2)
   - Diagrama de componentes (C4 Level 3) para Gateway e Cost Engine
5. **Defina** a modelagem de dados:
   - **PostgreSQL:** Tenants, users, API keys, projects, teams, pricing tables, budgets
   - **ClickHouse:** Request logs, token usage events, cost events (time-series analytics)
   - **Redis:** Cache de token estimations, rate limiting counters, session data
6. **Especifique** contratos de API:
   - Gateway endpoints (proxy pass-through para LLM providers)
   - Dashboard API endpoints (metricas, filtros, exportacao)
   - Admin API endpoints (tenants, API keys, pricing)
   - Token Estimation API (pre-flight estimation)
   - Model Recommendation API (model ranking)
7. **Enderece** requisitos nao-funcionais:
   - **Latencia:** Overhead do proxy < 50ms (p99)
   - **Escalabilidade:** Horizontal scaling do Gateway, particionamento ClickHouse
   - **Seguranca:** API key auth, tenant isolation, request encryption
   - **Observabilidade:** OpenTelemetry traces, Prometheus metricas, Grafana dashboards
   - **Resiliencia:** Circuit breaker por LLM provider, retry com backoff, fallback
   - **Multi-tenancy:** Isolamento de dados por tenant, rate limiting por tenant
8. **Crie ADRs** para cada decisao arquitetural significativa:
   - ADR-001: Gateway como proxy reverso vs. SDK client-side
   - ADR-002: ClickHouse para analytics vs. TimescaleDB vs. Elasticsearch
   - ADR-003: Estrategia de token counting (pre-envio vs. pos-resposta)
   - ADR-004: Modelo de multi-tenancy (schema separation vs. row-level)
   - ADR-005: Estrategia de caching para estimativas de tokens

### Regras:

- Cada ADR deve seguir o formato: Titulo, Status, Contexto, Decisao, Consequencias.
- Diagramas devem ser descritos em formato Mermaid ou PlantUML.
- A arquitetura deve ser justificada em relacao aos requisitos.
- Trade-offs devem ser documentados explicitamente.
- O Gateway deve adicionar o minimo de latencia possivel ao fluxo LLM.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | Requisitos aprovados |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios de aceitacao |
| Project Brief | `output/requirements/project-brief.md` | Restricoes e preferencias tecnicas |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Documento completo de arquitetura TokenOps |
| ADRs | `output/architecture/adrs/adr-NNN-*.md` | Architecture Decision Records |

### Estrutura do architecture-design.md:

```markdown
# Arquitetura — TokenOps AI FinOps Platform

## 1. Visao Geral
[Estilo arquitetural e justificativa]

## 2. Diagrama de Contexto (C4 L1)
[TokenOps <-> LLM Providers, Users, External Systems]

## 3. Diagrama de Containers (C4 L2)
[AI Gateway, NestJS API, Next.js Frontend, PostgreSQL, ClickHouse, Redis]

## 4. Componentes Criticos (C4 L3)
### 4.1 AI Gateway Proxy
[Request flow, routing, circuit breaker]
### 4.2 Token Estimation Engine
[Tokenizer pipeline, caching]
### 4.3 Model Recommendation Engine
[Ranking algorithm, quality scoring]
### 4.4 Cost Engine
[Pricing tables, real-time calculation]
### 4.5 Analytics Pipeline
[Event ingestion, ClickHouse aggregations]

## 5. Modelagem de Dados
### 5.1 PostgreSQL (Operacional)
### 5.2 ClickHouse (Analytics)
### 5.3 Redis (Cache & Rate Limiting)

## 6. Contratos de API
### 6.1 Gateway API (LLM Proxy)
### 6.2 Dashboard API
### 6.3 Admin API
### 6.4 Token Estimation API
### 6.5 Model Recommendation API

## 7. Requisitos Nao-Funcionais
### 7.1 Latencia e Performance
### 7.2 Escalabilidade
### 7.3 Seguranca e Multi-tenancy
### 7.4 Observabilidade
### 7.5 Resiliencia

## 8. Stack Tecnologica
[NestJS, Next.js, PostgreSQL, ClickHouse, Redis + justificativas]

## 9. Trade-offs
[Decisoes e suas consequencias]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `architect`
- **Skills:** `design-architecture`, `create-adr`
- **Timeout:** 60 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 05, verifique:

- [ ] Estilo arquitetural definido e justificado
- [ ] Diagramas C4 (pelo menos L1 e L2) presentes
- [ ] AI Gateway proxy design completo (routing, circuit breaker, rate limiting)
- [ ] Token Estimation Engine projetado
- [ ] Model Recommendation Engine projetado
- [ ] Cost Engine com pricing tables definido
- [ ] Analytics pipeline com ClickHouse projetada
- [ ] Modelagem de dados para PostgreSQL, ClickHouse e Redis
- [ ] Contratos de API especificados (Gateway, Dashboard, Admin, Estimation, Recommendation)
- [ ] Multi-tenancy e isolamento de dados enderecados
- [ ] Pelo menos 5 ADRs criados
- [ ] Trade-offs documentados
- [ ] Stack tecnologica alinhada com o briefing
