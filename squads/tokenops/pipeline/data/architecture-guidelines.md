# Architecture Guidelines — TokenOps

## Principios
1. **Simplicidade**: A solucao mais simples que resolve o problema e a melhor
2. **Separacao de Concerns**: Cada modulo/servico tem uma responsabilidade clara
3. **Loose Coupling**: Dependencias explicitas e minimizadas entre componentes
4. **High Cohesion**: Funcionalidades relacionadas ficam juntas
5. **Fail Fast**: Erros sao detectados e reportados o mais cedo possivel
6. **Cost Awareness**: Toda decisao arquitetural considera impacto em custo de tokens e infra

## Visao Geral da Arquitetura

### Modulos Core
| Modulo | Responsabilidade |
|--------|-----------------|
| **AI Gateway Proxy** | Proxy reverso para LLM providers, roteamento, rate limiting, caching |
| **Token Estimator** | Estimativa de consumo de tokens pre-request, tokenizacao por modelo |
| **Model Recommendation** | Recomendacao de modelo otimo baseado em custo/qualidade/latencia |
| **Prompt Optimization** | Sugestoes de otimizacao de prompts para reduzir consumo de tokens |
| **Remediation Engine** | Acoes automaticas e alertas quando limites de custo sao atingidos |
| **Dashboard** | Visualizacao de metricas, custos, trends e insights em tempo real |

### Camadas
```
[Dashboard - Next.js] --> [API Layer - NestJS]
                              |
              +---------------+---------------+
              |               |               |
        [Gateway Proxy] [Estimator]  [Recommendation]
              |               |               |
        [LLM Providers]  [Token DB]   [Model Registry]
              |
        [Analytics Pipeline] --> [ClickHouse]
```

## Decisoes Arquiteturais (ADRs)
- Toda decisao significativa gera um ADR
- ADRs sao imutaveis — se a decisao mudar, cria-se um novo ADR que a supersede
- Formato: Contexto -> Decisao -> Consequencias -> Alternativas Consideradas
- ADRs armazenados em `docs/adr/` com numeracao sequencial

## Padroes de API
- **REST** para CRUD e operacoes de configuracao (users, orgs, billing, settings)
- **REST + Streaming** para o Gateway Proxy (SSE para streaming de respostas LLM)
- **WebSocket** para Dashboard real-time (metricas live, alertas)
- **Event-driven (pub/sub)** para pipeline de analytics e remediation triggers
- **gRPC** (futuro) para comunicacao interna entre microservicos se escalar

## Gateway Proxy Patterns
- **Reverse Proxy**: intercepta requests para LLM providers (OpenAI, Anthropic, Google, etc.)
- **Request Enrichment**: adiciona metadata de tracking (org_id, project_id, request_id)
- **Response Interception**: captura usage data (tokens_in, tokens_out, latency, model)
- **Circuit Breaker**: fallback para provider alternativo em caso de falha
- **Rate Limiting**: por organizacao, projeto e usuario com token bucket algorithm
- **Semantic Cache**: cache de respostas baseado em similaridade semantica do prompt
- **Load Balancing**: distribuicao entre providers com base em custo e disponibilidade

## Event-Driven Analytics
- Cada request/response pelo Gateway emite evento para fila (Redis Streams ou Bull)
- Worker processa eventos e persiste em ClickHouse para analytics
- Aggregacoes pre-computadas para dashboard (hourly, daily, monthly)
- Materialized views no ClickHouse para queries frequentes
- Retention policy: dados granulares por 90 dias, agregados por 2 anos

## Armazenamento de Dados
| Store | Uso |
|-------|-----|
| **PostgreSQL** | Dados transacionais (users, orgs, projects, configs, billing) |
| **ClickHouse** | Analytics de uso de tokens (alta ingestao, queries analiticas) |
| **Redis** | Cache (respostas, sessions), filas (eventos), rate limiting counters |

## Seguranca
- Zero Trust: nunca confiar, sempre verificar
- Autenticacao via JWT + API Keys para integracao programatica
- RBAC: roles por organizacao (owner, admin, member, viewer)
- Principle of Least Privilege para acessos a dados e APIs
- Encryption at rest (AES-256) e in transit (TLS 1.3) obrigatorios
- API Keys hasheadas no banco — nunca armazenar em plaintext
- Secrets em vault (nunca em codigo ou env files commitados)
- Rate limiting e throttling em todas as endpoints publicas
- Audit log para acoes administrativas

## Observabilidade
- **OpenTelemetry SDK** integrado em todos os servicos NestJS
- **Traces**: distributed tracing de ponta a ponta (request -> gateway -> LLM -> response)
- **Metrics**: Prometheus exporters para latencia, throughput, token usage, error rates
- **Logs**: Structured logging (JSON) com correlation ID em toda request chain
- **Dashboards**: Grafana com dashboards pre-configurados por modulo
- Health check endpoints obrigatorios em todos os servicos
- Alertas baseados em SLOs, nao em thresholds arbitrarios
- SLOs definidos: 99.9% uptime gateway, p95 latencia < 200ms (excluindo LLM), error rate < 0.1%

## Multi-Tenancy
- Tenant isolation via `organization_id` em todas as tabelas
- Row-level security no PostgreSQL para queries multi-tenant
- Namespace isolation no Redis (`{org_id}:cache:`, `{org_id}:rate:`)
- ClickHouse partitioning por `organization_id` para performance
- Nenhum dado de tenant A deve ser acessivel por tenant B — validacao em middleware
