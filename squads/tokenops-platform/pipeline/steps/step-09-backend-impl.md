---
step: "09"
name: "Implementacao Backend — NestJS APIs, Gateway Proxy, LLM Adapters"
type: agent
agent: dev-backend
tasks:
  - implement-api
  - implement-gateway-proxy
  - implement-llm-integrations
  - implement-token-estimator
  - implement-model-recommendation
  - model-database
  - write-unit-tests
depends_on: step-08
phase: implementation
---

# Step 09: Implementacao Backend — NestJS APIs, Gateway Proxy, LLM Adapters

## Para o Pipeline Runner

O agente Developer Backend deve implementar toda a camada backend do TokenOps Platform MVP, seguindo a arquitetura definida no Step 04, as user stories aprovadas, e o sprint backlog do Step 06. A implementacao deve seguir a estrutura modular do NestJS e incluir testes unitarios.

### Componentes a implementar:

1. **NestJS Project Scaffold (Modular Architecture)**:
   - `GatewayModule`: AI Gateway proxy, request interception, routing
   - `EstimatorModule`: Token estimation engine, cost calculation
   - `RecommenderModule`: Model recommendation scoring engine
   - `AnalyticsModule`: Event pipeline, ClickHouse consumers, aggregation
   - `PlatformModule`: Auth, users, orgs, teams, API keys, billing
   - Shared: DTOs, interfaces, guards, interceptors, pipes
   - Config: environment-based configuration (NestJS ConfigModule)

2. **AI Gateway Proxy**:
   - Request interception middleware/interceptor
   - Token counting pre-execution (estimativa) e post-execution (real)
   - Cost calculation engine com pricing tables por modelo/provider
   - Routing rules engine (provider selection, fallback)
   - Response caching (Redis, semantic hash)
   - Rate limiting por org/API key (Redis)
   - Streaming support (SSE passthrough)
   - Request/response logging (event emission)

3. **LLM Adapter Pattern (7 Providers)**:
   - Interface base `LLMAdapter`:
     ```typescript
     interface LLMAdapter {
       complete(request: CompletionRequest): Promise<CompletionResponse>;
       stream(request: CompletionRequest): AsyncIterable<StreamChunk>;
       embed(request: EmbeddingRequest): Promise<EmbeddingResponse>;
       estimateTokens(prompt: string, model: string): Promise<TokenEstimate>;
       listModels(): Promise<ModelInfo[]>;
     }
     ```
   - Adapters concretos: OpenAIAdapter, AnthropicAdapter, GeminiAdapter, AzureOpenAIAdapter, BedrockAdapter, GroqAdapter, DeepSeekAdapter
   - Token counting especifico por provider (tiktoken para OpenAI/Azure, contagem nativa para Anthropic, etc.)
   - Pricing tables configuravel (JSON/DB, nao hardcoded)
   - Circuit breaker pattern (fallback entre providers)
   - Health check por provider

4. **Token Estimator Engine**:
   - Estimativa pre-execucao de tokens de input
   - Estimativa de tokens de output (baseada em historico e heuristicas)
   - Calculo de custo estimado (input tokens * price + output tokens * price)
   - Comparacao multi-modelo (mesmo prompt, diferentes modelos/providers)
   - Cache de estimativas (prompt hash -> resultado)

5. **Model Recommendation Engine**:
   - Scoring algorithm multi-fatorial:
     - Complexidade da task (simple, moderate, complex, expert)
     - Tamanho do contexto (short, medium, long, very-long)
     - Criticidade (low, medium, high, critical)
     - Requisito de latencia (real-time, near-real-time, batch)
     - Budget constraint (cost ceiling)
   - Ranking de modelos por score ponderado
   - Explicabilidade (por que cada modelo foi recomendado)
   - Historico de recomendacoes e feedback loop

6. **PostgreSQL Schemas (OLTP)**:
   - `users`: id, email, name, password_hash, role, org_id, created_at
   - `organizations`: id, name, slug, plan, settings, created_at
   - `teams`: id, name, org_id, created_at
   - `projects`: id, name, team_id, org_id, settings, created_at
   - `api_keys`: id, key_hash, name, org_id, project_id, permissions, rate_limit, expires_at
   - `billing`: id, org_id, plan, stripe_customer_id, stripe_subscription_id, status
   - Migrations com TypeORM ou Prisma

7. **ClickHouse Schemas (OLAP)**:
   - `prompt_logs`: timestamp, org_id, project_id, user_id, model, provider, prompt_hash, input_tokens, output_tokens, latency_ms, status
   - `token_usage`: timestamp, org_id, project_id, model, provider, input_tokens, output_tokens, estimated_tokens, cost_usd
   - `cost_events`: timestamp, org_id, project_id, model, provider, event_type, amount_usd, metadata
   - Materialized views para aggregacoes (por hora, dia, semana, mes)
   - Particionamento por mes

8. **Redis Cache**:
   - Response cache: semantic hash de prompts -> cached response
   - Rate limiting: sliding window por org/API key
   - Session cache: dashboard real-time data
   - Token estimation cache: prompt hash + model -> estimativa

9. **Unit Tests (Jest)**:
   - Testes para token counting algorithms
   - Testes para cost calculation engine
   - Testes para model recommendation scoring
   - Testes para cada LLM adapter (com mocks)
   - Testes para gateway routing rules
   - Testes para rate limiting logic
   - Coverage target: 80%+

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Design de referencia para implementacao |
| ADRs | `output/architecture/adrs/` | Decisoes tecnicas a seguir |
| User Stories | `output/requirements/user-stories.md` | Stories MVP a implementar |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios para validar implementacao |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Sequencia de implementacao |
| Test Strategy | `output/planning/test-strategy.md` | Diretrizes de testes |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Backend Source | `output/implementation/backend/` | Codigo fonte NestJS completo |
| API Contracts | `output/implementation/backend/api-contracts.md` | Endpoints REST documentados |
| DB Migrations | `output/implementation/backend/migrations/` | Scripts de migracao PostgreSQL e ClickHouse |
| Test Results | `output/implementation/backend/test-results.md` | Relatorio de cobertura de testes |

### Estrutura de `output/implementation/backend/`

```
backend/
  src/
    gateway/          # GatewayModule
    estimator/        # EstimatorModule
    recommender/      # RecommenderModule
    analytics/        # AnalyticsModule
    platform/         # PlatformModule (auth, users, orgs, billing)
    adapters/         # LLM Adapters (7 providers)
    shared/           # DTOs, interfaces, guards, interceptors
    config/           # Configuration
  test/
    unit/
    integration/
  migrations/
  api-contracts.md
  test-results.md
```

## Execution Mode

- **Tipo**: Agent (dev-backend)
- **Requer input do usuario**: Nao — agente implementa autonomamente com base nos artifacts
- **Automatizavel**: Sim
- **Tempo estimado**: 40-60 minutos de execucao do agente (maior step do pipeline)

## Quality Gate

- [ ] Estrutura modular NestJS implementada (5 modulos)
- [ ] AI Gateway proxy funcional com token counting e cost calculation
- [ ] Todos os 7 LLM adapters implementados e testados
- [ ] Token Estimator engine funcional com estimativa pre-execucao
- [ ] Model Recommendation Engine com scoring multi-fatorial
- [ ] PostgreSQL schemas criados com migrations
- [ ] ClickHouse schemas criados com materialized views
- [ ] Redis cache configurado (response cache, rate limiting)
- [ ] Unit tests passando com 80%+ coverage
- [ ] API contracts documentados
- [ ] Nenhum secret hardcoded (usar environment variables)
- [ ] Error handling consistente em todos os modulos
