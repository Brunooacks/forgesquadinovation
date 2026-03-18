---
step: "18"
name: "Deploy em Producao"
type: agent
agent: dev-backend
tasks:
  - create-integration
depends_on: step-17
phase: deployment
---

# Step 18: Dev Backend — Deploy em Producao

## Para o Pipeline Runner

Acione o agente `dev-backend` com a task `create-integration`. O desenvolvedor
backend deve configurar e executar o deploy em producao seguindo o runbook
e utilizando ferramentas de infraestrutura como StackSpot.

### Instrucoes para o Agente:

1. **Leia** o runbook operacional para procedimento de deploy.
2. **Verifique** pre-requisitos:
   - Ambiente de producao acessivel.
   - Variaveis de ambiente configuradas.
   - Banco de dados preparado para migrations.
   - Servicos dependentes disponiveis.
   - Backup do estado atual realizado.
3. **Configure** infraestrutura (se necessario):
   - Provisione recursos via StackSpot ou IaC.
   - Configure DNS e load balancer.
   - Configure certificados SSL.
   - Configure monitoramento e alertas.
4. **Execute** o deploy:
   - Aplique migrations de banco de dados.
   - Deploy da aplicacao backend.
   - Deploy da aplicacao frontend.
   - Configure CDN (se aplicavel).
5. **Valide** o deploy:
   - Execute health checks.
   - Verifique endpoints criticos.
   - Valide integracao com servicos externos.
   - Confirme metricas de monitoramento.
   - Execute smoke tests.
6. **Documente** o resultado:
   - Versao deployada.
   - Timestamp do deploy.
   - Resultados dos health checks.
   - Metricas iniciais de producao.

### Ferramentas Recomendadas:

- **StackSpot** para provisionamento de infraestrutura.
- **GitHub Actions / GitLab CI** para pipeline de CI/CD.
- **Docker / Kubernetes** para containerizacao.
- **Terraform / Pulumi** para IaC.

### Regras:

- Seguir rigorosamente o runbook.
- Ter procedimento de rollback pronto antes de iniciar.
- Monitorar metricas por pelo menos 15 minutos apos deploy.
- Se smoke tests falharem, executar rollback imediato.
- Comunicar stakeholders sobre inicio e fim do deploy.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Runbook | `output/documentation/runbook.md` | Procedimento de deploy |
| Backend Code | `output/implementation/backend/` | Codigo a ser deployado |
| Frontend Code | `output/implementation/frontend/` | Codigo a ser deployado |
| Go/No-Go Record | `output/deployment/go-nogo-record.md` | Autorizacao de deploy |
| Architecture Design | `output/architecture/architecture-design.md` | Referencia de infraestrutura |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Deploy Report | `output/deployment/deploy-report.md` | Relatorio detalhado do deploy |

### Estrutura do deploy-report.md:

```markdown
# Deploy Report — [Nome do Projeto]

## Resumo
- **Status:** SUCESSO / FALHA / ROLLBACK
- **Versao:** [versao]
- **Data/Hora inicio:** [timestamp]
- **Data/Hora fim:** [timestamp]
- **Duracao:** [minutos]
- **Responsavel:** dev-backend

## Ambiente
- **URL Producao:** [url]
- **Cloud Provider:** [provider]
- **Regiao:** [regiao]

## Checklist de Deploy
- [x] Pre-requisitos verificados
- [x] Backup realizado
- [x] Migrations aplicadas
- [x] Backend deployado
- [x] Frontend deployado
- [x] Health checks OK
- [x] Smoke tests OK

## Health Checks
| Endpoint | Status | Response Time |
|----------|--------|--------------|
| /health | 200 OK | [X]ms |
| /api/v1/status | 200 OK | [X]ms |

## Smoke Tests
| Teste | Resultado |
|-------|-----------|
| Login flow | PASS |
| [Fluxo critico] | PASS |

## Metricas Pos-Deploy (15 min)
| Metrica | Valor | Status |
|---------|-------|--------|
| Error rate | [X%] | OK |
| p95 latency | [X]ms | OK |
| CPU usage | [X%] | OK |
| Memory usage | [X%] | OK |

## Incidentes (se houver)
[Descricao de incidentes durante deploy]

## Procedimento de Rollback (se executado)
[Detalhes do rollback]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `dev-backend`
- **Skills:** `create-integration`
- **Timeout:** 45 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 19, verifique:

- [ ] Deploy executado com sucesso
- [ ] Health checks passando
- [ ] Smoke tests passando
- [ ] Metricas de producao estaveis por 15 minutos
- [ ] Nenhum incidente critico pos-deploy
- [ ] Relatorio de deploy gerado
- [ ] Monitoramento e alertas ativos
