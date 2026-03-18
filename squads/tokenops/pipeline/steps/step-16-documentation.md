---
step: "16"
name: "Documentacao Tecnica — API Docs, SDK Guide, Integration Guides"
type: agent
agent: tech-writer
tasks:
  - write-api-docs
  - write-sdk-guide
  - write-integration-guides
  - write-runbook
  - write-release-notes
depends_on: step-15
phase: documentation
---

# Step 16: Tech Writer — Documentacao Tecnica TokenOps

## Para o Pipeline Runner

Acione o agente `tech-writer` com as tasks `write-api-docs`, `write-sdk-guide`,
`write-integration-guides`, `write-runbook` e `write-release-notes`. O Tech Writer
deve gerar documentacao tecnica completa para o TokenOps, incluindo guias de
integracao com o Gateway para clientes.

### Instrucoes para o Agente:

1. **Leia** toda a documentacao existente (arquitetura, API, testes, reviews).

2. **Gere** documentacao de API:
   - **Gateway API:** Formato OpenAI-compatible, endpoints de proxy, headers customizados.
   - **Dashboard API:** Metricas, filtros, exportacao.
   - **Token Estimation API:** Endpoint de estimativa pre-envio.
   - **Model Recommendation API:** Endpoint de ranking.
   - **Admin API:** Gestao de tenants, API keys, projetos.
   - Autenticacao (API key no header, JWT para Dashboard).
   - Rate limiting headers e codigos de erro.
   - Exemplos com curl, httpie e SDKs.

3. **Gere** SDK/Integration Guide:
   - Como integrar com o TokenOps Gateway (substituir URL base do OpenAI/Anthropic).
   - Exemplos em Python, Node.js, e curl.
   - Como usar Token Estimation antes do envio.
   - Como interpretar headers de resposta (tokens usados, custo, modelo).
   - Migracao: como trocar de chamada direta para Gateway.

4. **Gere** guias de integracao por provider:
   - OpenAI -> TokenOps Gateway.
   - Anthropic -> TokenOps Gateway.
   - Google Gemini -> TokenOps Gateway.
   - AWS Bedrock -> TokenOps Gateway.
   - Azure OpenAI -> TokenOps Gateway.

5. **Gere** runbook operacional:
   - Pre-requisitos para deploy (PostgreSQL, ClickHouse, Redis).
   - Procedimento de deploy passo a passo.
   - Procedimento de rollback.
   - Health checks e como verificar.
   - Troubleshooting: Gateway timeout, ClickHouse lag, Redis full.
   - Monitoramento: dashboards Grafana, alertas Prometheus.
   - Escalamento horizontal do Gateway.

6. **Gere** release notes:
   - MVP Features: Gateway, Dashboard, Token Estimation, Model Recommendation.
   - Providers suportados.
   - Requisitos de infraestrutura.
   - Problemas conhecidos.
   - Roadmap pos-MVP (Cost Explorer, Alerts & Budgets).

### Regras:

- Documentacao deve ser clara para desenvolvedores que nunca usaram o TokenOps.
- API docs devem permitir integracao sem suporte humano.
- SDK guide deve permitir migracao em menos de 30 minutos.
- Runbook deve permitir deploy por alguem nao familiarizado com o projeto.
- Release notes devem seguir formato changelog padrao.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Referencia arquitetural |
| Backend Code | `output/implementation/backend/` | Codigo NestJS para referencia |
| Frontend Code | `output/implementation/frontend/` | Codigo Next.js para referencia |
| Test Report | `output/quality/test-report.md` | Resultados de testes |
| Performance Report | `output/quality/performance-report.md` | Resultados de performance |
| Code Review Report | `output/review/code-review-report.md` | Review findings |
| Arch Review Report | `output/review/arch-review-report.md` | Conformidade arquitetural |
| User Stories | `output/requirements/user-stories.md` | Features implementadas |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| API Docs | `output/documentation/api-docs.md` | Documentacao completa da API TokenOps |
| SDK Guide | `output/documentation/sdk-guide.md` | Guia de integracao e SDK |
| Integration Guides | `output/documentation/integration-guides.md` | Guias por LLM provider |
| Runbook | `output/documentation/runbook.md` | Guia operacional de deploy e manutencao |
| Release Notes | `output/documentation/release-notes.md` | Notas de release MVP |

### Estrutura do api-docs.md:

```markdown
# API Documentation — TokenOps

## Base URL
`https://gateway.tokenops.io/v1`

## Autenticacao
API Key via header: `Authorization: Bearer tk_...`

## Gateway API (LLM Proxy)

### POST /v1/chat/completions (OpenAI-compatible)
- **Descricao:** Proxy para chat completions
- **Headers customizados:**
  - `X-TokenOps-Project`: Project ID
  - `X-TokenOps-Model-Override`: Forcar modelo especifico
- **Response Headers:**
  - `X-TokenOps-Tokens-Used`: Tokens consumidos
  - `X-TokenOps-Cost`: Custo da chamada
  - `X-TokenOps-Model`: Modelo efetivo usado

## Token Estimation API
### POST /v1/estimate
...

## Model Recommendation API
### POST /v1/recommend
...

## Dashboard API
### GET /v1/dashboard/overview
...
```

### Estrutura do sdk-guide.md:

```markdown
# TokenOps SDK & Integration Guide

## Quick Start (5 minutos)
[Passo a passo minimo para integrar]

## Migracao do OpenAI
### Antes (direto)
### Depois (via TokenOps Gateway)

## Migracao do Anthropic
...

## Token Estimation
[Como estimar tokens antes de enviar]

## Model Recommendation
[Como usar recomendacoes]

## Best Practices
[Dicas de uso otimizado]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `tech-writer`
- **Skills:** `write-api-docs`, `write-sdk-guide`, `write-integration-guides`, `write-runbook`, `write-release-notes`
- **Timeout:** 45 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 17, verifique:

- [ ] API docs cobrem todos os endpoints (Gateway, Dashboard, Estimation, Recommendation, Admin)
- [ ] Exemplos de request/response para cada endpoint
- [ ] SDK Guide com exemplos em Python, Node.js e curl
- [ ] Guias de integracao para cada LLM provider
- [ ] Runbook completo com deploy, rollback e troubleshooting
- [ ] Release notes do MVP geradas
- [ ] Documentacao revisada para clareza e completude
- [ ] Todos os artefatos nos caminhos corretos
