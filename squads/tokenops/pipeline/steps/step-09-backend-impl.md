---
step: "09"
name: "Implementacao Backend — NestJS APIs, Gateway Proxy, LLM Integracoes"
type: agent
agent: dev-backend
tasks:
  - implement-api
  - implement-gateway-proxy
  - implement-llm-integrations
  - model-database
  - write-unit-tests
depends_on: step-08
phase: implementation
---

# Step 09: Dev Backend — Implementacao Backend TokenOps

## Para o Pipeline Runner

Acione o agente `dev-backend` com as tasks `implement-api`, `implement-gateway-proxy`,
`implement-llm-integrations`, `model-database` e `write-unit-tests`. O desenvolvedor
backend deve implementar o core do TokenOps: AI Gateway proxy, Token Estimation Engine,
Model Recommendation Engine, Cost Engine e as APIs do Dashboard.

### Instrucoes para o Agente:

1. **Leia** a arquitetura, contratos de API, modelagem de dados e ADRs.
2. **Configure** o projeto NestJS:
   - Estrutura modular conforme arquitetura (gateway, estimation, recommendation, cost, dashboard, platform).
   - TypeScript strict mode.
   - Dependencias: @nestjs/*, TypeORM/Prisma, ioredis, clickhouse-client, tiktoken.
   - Variaveis de ambiente (.env.example).
   - Docker Compose para desenvolvimento local (PostgreSQL, ClickHouse, Redis).

3. **Implemente** a modelagem de dados:
   - **PostgreSQL:** Tenants, Users, API Keys, Projects, Teams, Pricing Tables, Budgets.
   - **ClickHouse:** Request logs, Token usage events, Cost events (time-series).
   - **Redis:** Token estimation cache, Rate limiting counters, Session data.
   - Migrations de banco de dados (PostgreSQL).
   - Seeders com pricing tables dos provedores LLM.

4. **Implemente** o AI Gateway Proxy:
   - Endpoint proxy que aceita requests no formato OpenAI-compatible.
   - LLM Provider Adapters (OpenAI, Anthropic, Google Gemini, AWS Bedrock, Azure OpenAI).
   - Request interception: token counting pre/pos, cost calculation.
   - Routing inteligente entre providers (round-robin, weighted, failover).
   - Rate limiting por tenant/API key (Redis-based).
   - Circuit breaker por provider (com estado em Redis).
   - Request/response logging assincrono para ClickHouse.
   - Streaming support (SSE) para respostas LLM.

5. **Implemente** o Token Estimation Engine:
   - Tokenizer por modelo (tiktoken para OpenAI, estimativas para outros).
   - API de estimativa pre-envio: prompt -> estimated_tokens + estimated_cost.
   - Cache de estimativas em Redis (TTL configuravel).
   - Batch estimation para multiplos prompts.

6. **Implemente** o Model Recommendation Engine:
   - Pricing tables atualizaveis por provider/modelo.
   - Algoritmo de ranking: custo vs. qualidade vs. latencia.
   - API de recomendacao: task_description + constraints -> ranked_models.
   - Historico de performance por modelo (baseado em dados do Gateway).

7. **Implemente** o Cost Engine:
   - Calculo de custo em tempo real por request (input_tokens * price + output_tokens * price).
   - Agregacao por tenant/time/projeto/modelo.
   - Pricing tables atualizaveis via Admin API.

8. **Implemente** as Dashboard APIs:
   - Overview: metricas agregadas (total tokens, total cost, total requests).
   - Usage by period: graficos de uso por dia/semana/mes.
   - Cost by model: breakdown de custo por modelo/provider.
   - Filtros: period, team, project, model, provider.
   - Exportacao de dados (CSV, JSON).

9. **Implemente** Platform (cross-cutting):
   - Multi-tenancy com row-level isolation.
   - Autenticacao JWT + API key auth para Gateway.
   - CRUD de API keys.
   - CRUD de projetos e times.
   - Admin API para gestao de tenants.

10. **Escreva** testes unitarios:
    - Token Estimation Engine: precisao por modelo, edge cases.
    - Cost Engine: calculos, pricing, agregacoes.
    - Model Recommendation: ranking, scoring.
    - Gateway: routing logic, rate limiting, circuit breaker.
    - Dashboard APIs: filtros, paginacao, agregacoes.

11. **Configure** observabilidade:
    - OpenTelemetry tracing (request lifecycle no Gateway).
    - Prometheus metricas (latency, throughput, error rate por provider).
    - Logging estruturado (JSON, correlation IDs).
    - Health check endpoints.

### Ferramentas Recomendadas:

- **Devin** para implementacao autonoma de adapters LLM e Token Estimation Engine.
- **GitHub Copilot** para autocompletar e sugestoes de codigo NestJS.
- **StackSpot AI** para aplicar padroes NestJS da organizacao.

### Regras:

- Seguir os padroes de codigo definidos na arquitetura e em `pipeline/data/coding-standards.md`.
- Cada endpoint deve ter pelo menos 1 teste unitario.
- Cobertura minima de testes unitarios: conforme test-strategy.md.
- Nenhum segredo hardcoded no codigo (usar .env).
- Todos os erros devem ter codigos e mensagens padronizados.
- O Gateway deve adicionar o minimo de latencia possivel (target: < 50ms overhead).
- Todas as operacoes de IO devem ser assincronas.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Contratos de API, modelagem de dados |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Tarefas de backend atribuidas |
| Test Strategy | `output/planning/test-strategy.md` | Metas de cobertura e precisao |
| ADRs | `output/architecture/adrs/` | Decisoes arquiteturais |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Backend Code | `output/implementation/backend/` | Codigo fonte NestJS completo |
| Unit Tests | `output/implementation/backend/tests/` | Testes unitarios |
| Migration Files | `output/implementation/backend/migrations/` | Migrations PostgreSQL |
| Backend Report | `output/implementation/backend/implementation-report.md` | Relatorio de implementacao |

## Execution Mode

- **Modo:** Subagent
- **Agente:** `dev-backend`
- **Skills:** `implement-api`, `implement-gateway-proxy`, `implement-llm-integrations`, `model-database`, `write-unit-tests`
- **Timeout:** 90 minutos
- **Retries:** 2

## Quality Gate

Antes de avancar para o Step 10, verifique:

- [ ] AI Gateway proxy implementado com suporte a 5 LLM providers
- [ ] Token Estimation Engine funcional com tokenizers por modelo
- [ ] Model Recommendation Engine com ranking custo/qualidade
- [ ] Cost Engine com calculo em tempo real
- [ ] Dashboard APIs implementadas (overview, usage, cost, filtros)
- [ ] Multi-tenancy com isolamento por tenant
- [ ] Autenticacao JWT + API key implementada
- [ ] Modelagem de dados completa (PostgreSQL + ClickHouse + Redis)
- [ ] Testes unitarios passando
- [ ] Cobertura de testes dentro da meta
- [ ] Gateway latency overhead < 50ms (baseline test)
- [ ] Nenhum segredo hardcoded
- [ ] Logging estruturado e OpenTelemetry configurados
- [ ] Health check endpoints funcionais
- [ ] Codigo segue padroes NestJS da arquitetura
