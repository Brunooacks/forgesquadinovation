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

# Step 18: Deploy SaaS em Producao

## Para o Pipeline Runner

O Backend Developer cria a configuracao de deployment e executa o deploy do TokenOps em producao. O Pipeline Runner deve invocar o agente dev-backend com a task create-integration. O agente deve produzir todos os artefatos de infraestrutura, CI/CD, e executar o deployment completo do MVP.

### Escopo do deployment:

1. **Docker Containers**:
   - Dockerfile para backend NestJS (multi-stage build, otimizado para producao)
   - Dockerfile para frontend Next.js (standalone build)
   - docker-compose.yml para ambiente de desenvolvimento local
   - Container registry (ECR, ACR ou GHCR)

2. **CI/CD Pipeline (GitHub Actions)**:
   - Workflow de build e test (trigger em PR para main)
   - Workflow de deploy para staging (trigger em merge para develop)
   - Workflow de deploy para producao (trigger em tag release)
   - Steps: lint, type-check, unit tests, integration tests, build, push image, deploy
   - Rollback automatico em caso de health check failure

3. **Configuracao de Ambiente**:
   - Environment variables por ambiente (dev, staging, production)
   - Secrets management (AWS Secrets Manager, Azure Key Vault, ou GitHub Secrets)
   - Configuracao de feature flags para rollout gradual
   - Environment-specific configs (database URLs, Redis URLs, API keys de providers)

4. **Database Migrations**:
   - PostgreSQL migrations (TypeORM ou Prisma)
   - ClickHouse schema setup (tables, materialized views, TTL policies)
   - Seed data para tabelas de referencia (modelos, pricing, providers)
   - Rollback scripts para cada migracao

5. **Secrets Management**:
   - API keys de LLM providers armazenadas em secrets manager
   - Database credentials rotacionaveis
   - JWT signing keys
   - Encryption keys para API keys de tenants

6. **Monitoring Setup**:
   - OpenTelemetry Collector configurado
   - Prometheus scraping de metricas do NestJS
   - Grafana dashboards: Gateway latencia/throughput, Token usage, Costs, Errors
   - Alertas: alta latencia (>100ms P95), error rate (>1%), disk usage (>80%)
   - Log aggregation (Loki, CloudWatch, ou similar)

7. **Health Checks**:
   - /health endpoint no backend (checks: DB, Redis, ClickHouse)
   - /ready endpoint (readiness probe para Kubernetes)
   - /live endpoint (liveness probe)
   - Frontend health check (page load validation)

8. **Auto-Scaling**:
   - Horizontal pod autoscaler (HPA) baseado em CPU e request count
   - Scaling rules: min 2 replicas, max 10, target CPU 70%
   - Database connection pool sizing por replica
   - Redis connection limits

9. **Deploy Execution**:
   - Deploy em ambiente de staging para validacao final
   - Smoke tests automatizados pos-deploy
   - Promover staging -> production apos validacao
   - Monitorar metricas nos primeiros 30 minutos pos-deploy

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Go/No-Go report | `output/reports/go-nogo-report.md` | Decisao Go aprovada |
| Architecture document | `output/architecture/architecture-document.md` | Arquitetura de referencia |
| Backend source code | `output/implementation/` | Codigo-fonte backend |
| Frontend source code | `output/implementation/` | Codigo-fonte frontend |
| Database schema | `output/architecture/database-schema.md` | Schemas de banco |
| Runbook | `output/documentation/runbook.md` | Guia operacional |
| Performance report | `output/quality/performance-report.md` | Baselines de performance |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Deploy Report | `output/deployment/deploy-report.md` | Relatorio completo do deployment com status, URLs, configuracoes e metricas pos-deploy |

### Estrutura do deploy-report.md

```
# TokenOps Platform — Deploy Report
## 1. Resumo Executivo
## 2. Infraestrutura Provisionada
### 2.1 Containers e Registry
### 2.2 Databases (PostgreSQL, ClickHouse, Redis)
### 2.3 Networking e DNS
## 3. CI/CD Pipeline
### 3.1 Workflows Configurados
### 3.2 Environments (dev, staging, production)
## 4. Database Migrations
## 5. Secrets Management
## 6. Monitoring e Alertas
### 6.1 Dashboards Grafana
### 6.2 Alertas Configurados
## 7. Health Checks e Auto-Scaling
## 8. Deploy Execution
### 8.1 Staging Deploy
### 8.2 Smoke Tests
### 8.3 Production Deploy
## 9. Metricas Pos-Deploy (primeiros 30 min)
## 10. URLs de Producao
## 11. Rollback Procedure
```

## Execution Mode

- **Tipo**: Agent (automatizado)
- **Agente**: dev-backend
- **Tasks**: create-integration
- **Automatizavel**: Sim — execucao pelo agente com configuracoes definidas
- **Tempo estimado**: 4-6 horas de execucao

## Quality Gate

- [ ] Dockerfiles criados e otimizados (multi-stage build)
- [ ] CI/CD pipeline configurado com build, test e deploy
- [ ] Database migrations executadas com sucesso (PostgreSQL + ClickHouse)
- [ ] Secrets armazenados em secrets manager (nao em environment files)
- [ ] Monitoring configurado (OpenTelemetry + Prometheus + Grafana)
- [ ] Health checks respondendo corretamente (/health, /ready, /live)
- [ ] Auto-scaling configurado (min 2, max 10 replicas)
- [ ] Staging deploy validado com smoke tests
- [ ] Production deploy executado com sucesso
- [ ] Metricas pos-deploy dentro dos budgets de performance
- [ ] Rollback procedure testado e documentado
- [ ] Relatorio deploy-report.md gerado com URLs de producao
