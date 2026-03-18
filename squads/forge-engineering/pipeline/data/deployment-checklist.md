# Deployment Checklist

## Pré-Deploy
- [ ] Todos os testes passando (unit, integration, E2E)
- [ ] Code review aprovado
- [ ] Quality gate do SonarQube passando
- [ ] Migrations de banco de dados testadas em staging
- [ ] Feature flags configuradas (se aplicável)
- [ ] Rollback plan documentado
- [ ] Runbook atualizado
- [ ] Release notes escritas
- [ ] Stakeholders notificados

## Durante o Deploy
- [ ] Deploy em staging primeiro
- [ ] Smoke tests em staging passando
- [ ] Métricas de baseline capturadas
- [ ] Deploy em produção (blue/green ou canary)
- [ ] Health checks passando
- [ ] Smoke tests em produção passando

## Pós-Deploy
- [ ] Métricas de produção dentro dos SLOs
- [ ] Sem aumento de error rate
- [ ] Sem degradação de latência
- [ ] Logs sem erros inesperados
- [ ] Alertas configurados e funcionando
- [ ] Feature flags ativadas gradualmente (se aplicável)
- [ ] Stakeholders notificados do sucesso
