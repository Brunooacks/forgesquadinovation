---
step: "18"
name: "Deploy SaaS em Producao"
type: agent
agent: dev-backend
tasks:
  - create-integration
depends_on: step-17
phase: deployment
---

# Step 18: Dev Backend — Deploy SaaS TokenOps em Producao

## Para o Pipeline Runner

Acione o agente `dev-backend` com a task `create-integration`. O desenvolvedor
backend deve configurar e executar o deploy do TokenOps como SaaS em producao,
incluindo o AI Gateway proxy, APIs NestJS, Dashboard Next.js e toda a infraestrutura
de dados (PostgreSQL, ClickHouse, Redis).

### Instrucoes para o Agente:

1. **Leia** o runbook operacional para procedimento de deploy.
2. **Verifique** pre-requisitos:
   - Ambiente de producao acessivel (cloud provider).
   - PostgreSQL provisionado e acessivel.
   - ClickHouse provisionado e acessivel.
   - Redis provisionado e acessivel.
   - Variaveis de ambiente configuradas (API keys LLM providers, DB credentials, etc.).
   - DNS configurado (gateway.tokenops.io, app.tokenops.io, api.tokenops.io).
   - Certificados SSL provisionados.
   - Backup do estado atual realizado (se existente).

3. **Configure** infraestrutura:
   - Provisione recursos via StackSpot ou IaC (Terraform/Pulumi).
   - Configure load balancer para o Gateway (alta disponibilidade).
   - Configure CDN para o Dashboard Next.js.
   - Configure auto-scaling para o Gateway (baseado em CPU/requests).
   - Configure monitoramento Grafana + Prometheus.
   - Configure alertas (latencia, error rate, disk usage).

4. **Execute** o deploy:
   - Aplique migrations PostgreSQL.
   - Crie schemas ClickHouse.
   - Seed pricing tables com dados atualizados dos providers.
   - Deploy do Gateway NestJS.
   - Deploy das APIs NestJS.
   - Deploy do Dashboard Next.js.
   - Configure Redis com rate limiting defaults.

5. **Valide** o deploy:
   - Execute health checks de todos os servicos.
   - Verifique conectividade: Gateway -> LLM providers.
   - Verifique conectividade: APIs -> PostgreSQL, ClickHouse, Redis.
   - Execute smoke tests:
     - Enviar request via Gateway -> verificar response.
     - Verificar log no ClickHouse.
     - Verificar metricas no Dashboard.
     - Estimar tokens via API.
     - Solicitar recomendacao de modelo via API.
   - Confirme metricas de monitoramento (Grafana dashboards).
   - Verifique rate limiting funcional.
   - Verifique multi-tenancy com tenant de teste.

6. **Documente** o resultado:
   - Versao deployada.
   - URLs de producao (Gateway, Dashboard, API).
   - Timestamp do deploy.
   - Resultados dos health checks.
   - Metricas iniciais (latencia, throughput).

### Ferramentas Recomendadas:

- **StackSpot** para provisionamento de infraestrutura.
- **GitHub Actions** para pipeline de CI/CD.
- **Docker / Kubernetes** para containerizacao.
- **Terraform / Pulumi** para IaC.
- **Grafana + Prometheus** para monitoramento.

### Regras:

- Seguir rigorosamente o runbook.
- Ter procedimento de rollback pronto antes de iniciar.
- Gateway deve ser o ultimo servico a receber trafego (apos APIs e dados validados).
- Monitorar metricas por pelo menos 15 minutos apos deploy.
- Se smoke tests falharem, executar rollback imediato.
- Comunicar stakeholders sobre inicio e fim do deploy.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Runbook | `output/documentation/runbook.md` | Procedimento de deploy |
| Backend Code | `output/implementation/backend/` | Codigo NestJS a ser deployado |
| Frontend Code | `output/implementation/frontend/` | Codigo Next.js a ser deployado |
| Go/No-Go Record | `output/deployment/go-nogo-record.md` | Autorizacao de deploy |
| Architecture Design | `output/architecture/architecture-design.md` | Referencia de infraestrutura |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Deploy Report | `output/deployment/deploy-report.md` | Relatorio detalhado do deploy SaaS |

### Estrutura do deploy-report.md:

```markdown
# Deploy Report — TokenOps SaaS

## Resumo
- **Status:** SUCESSO / FALHA / ROLLBACK
- **Versao:** [versao]
- **Data/Hora inicio:** [timestamp]
- **Data/Hora fim:** [timestamp]
- **Duracao:** [minutos]
- **Responsavel:** dev-backend

## URLs de Producao
- **Gateway:** https://gateway.tokenops.io
- **Dashboard:** https://app.tokenops.io
- **API:** https://api.tokenops.io
- **Grafana:** https://grafana.tokenops.io

## Ambiente
- **Cloud Provider:** [provider]
- **Regiao:** [regiao]
- **Kubernetes Cluster:** [cluster]

## Checklist de Deploy
- [x] Pre-requisitos verificados
- [x] PostgreSQL migrations aplicadas
- [x] ClickHouse schemas criados
- [x] Pricing tables seeded
- [x] Redis configurado
- [x] Gateway NestJS deployado
- [x] APIs NestJS deployadas
- [x] Dashboard Next.js deployado
- [x] Load balancer configurado
- [x] CDN configurado
- [x] SSL certificates ativos
- [x] Health checks OK
- [x] Smoke tests OK
- [x] Monitoramento ativo

## Health Checks
| Servico | Endpoint | Status | Response Time |
|---------|----------|--------|--------------|
| Gateway | /health | 200 OK | [X]ms |
| API | /health | 200 OK | [X]ms |
| Dashboard | / | 200 OK | [X]ms |

## Smoke Tests
| Teste | Resultado |
|-------|-----------|
| Gateway proxy request (OpenAI) | PASS |
| Gateway proxy request (Anthropic) | PASS |
| Token estimation | PASS |
| Model recommendation | PASS |
| Dashboard login | PASS |
| Dashboard metricas | PASS |
| Rate limiting | PASS |
| Multi-tenancy isolation | PASS |

## Metricas Pos-Deploy (15 min)
| Metrica | Valor | Status |
|---------|-------|--------|
| Gateway error rate | [X%] | OK |
| Gateway p95 latency | [X]ms | OK |
| Gateway p99 overhead | [X]ms | OK |
| API error rate | [X%] | OK |
| CPU usage | [X%] | OK |
| Memory usage | [X%] | OK |
| ClickHouse ingest lag | [X]s | OK |

## Incidentes (se houver)
[Descricao de incidentes durante deploy]

## Procedimento de Rollback (se executado)
[Detalhes do rollback]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `dev-backend`
- **Skills:** `create-integration`
- **Timeout:** 60 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 19, verifique:

- [ ] Deploy executado com sucesso
- [ ] Health checks passando (Gateway, API, Dashboard)
- [ ] Smoke tests passando (proxy, estimation, recommendation, dashboard)
- [ ] Gateway latency estavel (overhead < 50ms p99)
- [ ] Multi-tenancy funcional em producao
- [ ] Monitoramento Grafana operacional
- [ ] Metricas de producao estaveis por 15 minutos
- [ ] Nenhum incidente critico pos-deploy
- [ ] Relatorio de deploy gerado
