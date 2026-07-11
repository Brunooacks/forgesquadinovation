# Testing Strategy — TokenOps Platform

## Test Pyramid

```
        ┌───────────┐
        │   E2E     │  Few — critical user flows only
        │(Playwright)│
        ├───────────┤
        │Integration│  Some — module boundaries, DB, adapters
        │ (Jest +   │
        │Testcontain)│
        ├───────────┤
        │   Unit    │  Many — services, logic, adapters, utils
        │  (Jest)   │
        └───────────┘
```

Invest most effort in unit tests. Use integration tests to validate module boundaries and database interactions. Reserve E2E tests for critical business flows.

## Unit Tests (Jest)

**Scope**: Services, adapters, business logic, utilities, pipes, guards.

- Every service method has at least one test
- Mock all external dependencies (LLM providers, databases, Redis)
- Test edge cases: empty inputs, rate limit exceeded, provider timeout, invalid tokens
- Use factory functions for test data (`createMockEstimation()`, `createMockOrganization()`)
- Snapshot tests for DTOs and API response shapes
- Test error paths — exceptions thrown with correct codes and messages

**Key test targets**:
- `TokenEstimatorService` — accuracy of token counting across models
- `CostCalculatorService` — pricing logic for all providers and tiers
- `RecommenderService` — model selection based on task, budget, quality
- `GatewayService` — routing, fallback, circuit breaker logic
- LLM adapters — interface compliance, response transformation

## Integration Tests (Jest + Testcontainers)

**Scope**: Module boundaries, database queries, API endpoints.

- Use NestJS `TestingModule` for dependency injection
- Real PostgreSQL via Testcontainers — test migrations, queries, RLS policies
- Real Redis via Testcontainers — test caching, rate limiting
- ClickHouse via Testcontainers — test analytics ingestion and aggregation queries
- Test complete request/response cycle through controllers
- Verify multi-tenancy isolation: Org A cannot access Org B data

**Key test targets**:
- API key CRUD with hashing verification
- Usage analytics write and read pipeline
- Rate limiting enforcement across multiple requests
- Organization-scoped data isolation

## E2E Tests (Playwright)

**Scope**: Critical user-facing flows through the Dashboard.

- Run against a fully deployed local environment (Docker Compose)
- Test with realistic data (seeded via fixtures)
- Flows tested:
  - User login and organization selection
  - Dashboard overview — usage charts, cost summary, alerts
  - Token estimation — submit prompt, see estimation result
  - Model recommendation — request recommendation, compare options
  - API key management — create, view, revoke
  - Settings — update organization preferences, notification rules
- Visual regression tests for dashboard charts and layouts
- Accessibility checks (axe-core) on all pages

## Contract Tests

- Every LLM adapter must pass the `LlmProvider` interface contract test suite
- Contract test validates: `estimate()`, `execute()`, `executeStream()`, `getModels()`, `healthCheck()`
- When adding a new provider, run contract tests before merging
- Mock server for each provider to test without real API calls
- Verify response schema matches `LlmResponse` and `TokenEstimation` types

## Performance Tests (k6)

**Targets**:
- Gateway proxy latency: p50 < 20ms, p95 < 50ms, p99 < 100ms (excluding LLM response time)
- Throughput: sustain 10,000+ requests/second under load
- Estimation endpoint: p95 < 30ms
- Dashboard API: p95 < 200ms for aggregated queries
- WebSocket: support 5,000 concurrent connections

**Scenarios**:
- Steady-state: constant load at expected traffic
- Spike: 10x traffic burst for 5 minutes
- Soak: sustained load for 1 hour to detect memory leaks
- Stress: ramp until failure to find breaking point

## Coverage Requirements

| Scope | Minimum Coverage |
|-------|-----------------|
| Overall project | 80% |
| Gateway module | 90% |
| Estimator module | 90% |
| Recommender module | 85% |
| Optimizer module | 85% |
| Platform module | 80% |
| Dashboard (frontend) | 75% |

- Coverage enforced in CI — PR blocked if below threshold
- Coverage reports generated on every PR (Istanbul/nyc)

## CI/CD Integration

- **On every PR**:
  - Lint (ESLint + Prettier)
  - Type check (`tsc --noEmit`)
  - Unit tests (Jest, parallel)
  - Integration tests (Jest + Testcontainers)
  - Coverage check (fail if below threshold)
- **On merge to main**:
  - Full test suite including E2E (Playwright)
  - Build Docker images
  - Deploy to staging
- **Nightly**:
  - Performance tests (k6) against staging
  - Security scan (dependency audit, SAST)
  - Contract tests against live provider sandboxes

## Test Data Strategy

- **Mock LLM providers**: deterministic responses for unit/integration tests
- **Fixture factories**: `createUser()`, `createOrganization()`, `createApiKey()`, `createUsageRecord()`
- **Realistic prompts**: anonymized production prompts for performance and estimation accuracy tests
- **Seed scripts**: populate local/staging environments with representative data
- **No production data**: test environments never contain real customer data
- **Deterministic IDs**: use UUIDs generated from seeds for reproducible tests
