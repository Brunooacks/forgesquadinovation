# Architecture Guidelines — TokenOps Platform

## System Overview

```
Clients (Dashboard / API)
    │
    ▼
AI Gateway (Proxy Layer)
    │
    ├──▶ Optimization Engine (Estimator + Recommender + Optimizer)
    │
    ├──▶ LLM Providers (OpenAI, Anthropic, Google, Azure, Cohere, ...)
    │
    └──▶ Analytics Engine (Usage, Costs, Performance)
    │
    ▼
Dashboard (Real-time insights, reports, recommendations)
```

The AI Gateway intercepts all LLM requests, estimates token usage and cost before execution, applies optimization rules, routes to the best provider/model, and streams analytics asynchronously.

## Bounded Contexts

| Context | Responsibility | Key Entities |
|---------|---------------|--------------|
| **Gateway** | Proxy layer — intercepts, routes, and meters LLM requests | Request, Response, Route, RateLimit |
| **Estimator** | Pre-execution token counting and cost estimation | Estimation, TokenCount, PricingModel |
| **Recommender** | Model and provider recommendation based on task, cost, quality | Recommendation, ModelProfile, Benchmark |
| **Optimizer** | Prompt optimization, caching, batching strategies | OptimizationRule, PromptCache, BatchJob |
| **Remediation** | Automated actions on anomalies (budget alerts, throttling, fallback) | Alert, RemediationAction, Policy |
| **Dashboard** | Real-time visualization, reports, insights | Widget, Report, ChartConfig |
| **Platform** | Users, organizations, API keys, billing, settings | User, Organization, ApiKey, Plan |

## Dual-Database Strategy

### PostgreSQL (OLTP)
- Transactional data: users, organizations, API keys, projects, plans, billing
- TypeORM with migrations for schema management
- Row-level security (RLS) for multi-tenancy isolation
- Connection pooling via PgBouncer in production
- Indexes on frequently queried columns (org_id, created_at, status)

### ClickHouse (OLAP)
- Analytical data: token usage logs, latency metrics, cost records, model performance
- Columnar storage optimized for aggregations and time-series queries
- MergeTree engine with partitioning by month
- Materialized views for pre-aggregated dashboards
- Async ingestion — never blocks the request path

## Redis

- **Response cache**: key = hash(prompt + model + parameters), TTL based on model determinism
- **Rate limiting**: sliding window per tenant, per API key
- **Session management**: JWT refresh tokens, dashboard session state
- **Real-time pub/sub**: WebSocket event broadcasting for dashboard updates
- **Distributed locks**: for batch job coordination

## LLM Adapter Pattern

All LLM providers implement a common interface:

```typescript
interface LlmProvider {
  readonly name: string;
  readonly supportedModels: string[];

  estimate(request: LlmRequest): Promise<TokenEstimation>;
  execute(request: LlmRequest): Promise<LlmResponse>;
  executeStream(request: LlmRequest): AsyncGenerator<LlmChunk>;
  getModels(): Promise<ModelInfo[]>;
  healthCheck(): Promise<ProviderHealth>;
}
```

- New providers are added by implementing this interface
- Provider selection is dynamic based on routing rules
- Fallback chain: if primary provider fails, route to next available
- Circuit breaker pattern per provider to avoid cascading failures

## Event-Driven Analytics

- Every request through the Gateway emits an analytics event
- Events are written to an in-memory queue (BullMQ + Redis)
- Workers consume events and batch-insert into ClickHouse
- Zero impact on request latency — analytics is fully async
- Event schema: `{ traceId, orgId, model, inputTokens, outputTokens, latencyMs, cost, timestamp }`

## API Design

### REST (CRUD Operations)
- `/api/v1/organizations` — organization management
- `/api/v1/api-keys` — API key lifecycle
- `/api/v1/estimations` — token/cost estimation
- `/api/v1/recommendations` — model recommendations
- `/api/v1/usage` — usage reports and analytics
- Versioned endpoints (`/v1/`)
- Standard HTTP status codes, pagination via cursor

### WebSocket (Real-Time)
- `/ws/dashboard` — live usage metrics, cost updates, alerts
- `/ws/gateway` — streaming proxy responses
- Authenticated via token in connection handshake
- Heartbeat every 30 seconds

## Multi-Tenancy

- Organization-based tenant isolation
- PostgreSQL Row-Level Security (RLS) policies on all tenant tables
- ClickHouse queries always filtered by `org_id`
- Redis key prefix: `{org_id}:{resource}:{key}`
- API keys scoped to organization
- Rate limits and quotas per organization and plan tier
- Data never leaks between tenants — enforced at database level

## Observability

- **Tracing**: OpenTelemetry SDK, traces propagated through Gateway to providers
- **Metrics**: Prometheus exposition format, custom metrics for token usage, cost, latency
- **Logging**: Structured JSON logs with trace ID correlation
- **Dashboards**: Grafana dashboards for operations (latency, error rates, throughput) and business (cost savings, token usage trends)
- **Alerting**: Grafana alerting rules for SLA breaches, error spikes, budget thresholds

## Security

- API keys stored as bcrypt hashes — plaintext shown only once at creation
- TLS/HTTPS everywhere — no plaintext traffic
- Rate limiting per tenant and per API key (sliding window in Redis)
- Input validation on all endpoints (class-validator decorators)
- CORS configured per environment
- Secrets managed via external vault (never in code or environment files in repo)
- Audit log for sensitive operations (key creation, plan changes, data exports)
- OWASP top-10 mitigations enforced
