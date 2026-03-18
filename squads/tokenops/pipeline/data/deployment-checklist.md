# Deployment Checklist — TokenOps

## Pre-Deploy
- [ ] Todos os testes passando (unit, integration, E2E)
- [ ] Code review aprovado
- [ ] Quality gate do SonarQube passando
- [ ] Security scan (Snyk) sem vulnerabilidades criticas
- [ ] Migrations de banco testadas em staging (PostgreSQL e ClickHouse)
- [ ] Feature flags configuradas no sistema de feature management (se aplicavel)
- [ ] Rollback plan documentado (incluindo rollback de migrations)
- [ ] Runbook atualizado com novos procedimentos
- [ ] Release notes escritas
- [ ] Stakeholders notificados do deploy planejado
- [ ] API Keys e secrets atualizados no vault (se necessario)

## Validacao de Infraestrutura
- [ ] Redis: memoria disponivel suficiente para cache e filas
- [ ] PostgreSQL: migrations testadas, indices validados, conexoes pool configurado
- [ ] ClickHouse: schemas de analytics atualizados, materialized views recriadas se necessario
- [ ] OpenTelemetry Collector: configuracao atualizada para novos traces/metrics
- [ ] Prometheus: scrape configs atualizados para novos endpoints
- [ ] Grafana: dashboards atualizados com novas metricas

## Durante o Deploy

### Staging
- [ ] Deploy em staging primeiro
- [ ] Smoke tests em staging passando
- [ ] Gateway proxy: requests de teste para cada LLM provider configurado
- [ ] Token estimator: estimativas validadas contra consumo real
- [ ] Dashboard: metricas renderizando corretamente
- [ ] Metricas de baseline capturadas (latencia, throughput, error rate)

### Producao
- [ ] Deploy em producao (blue/green ou canary)
- [ ] Health checks passando em todos os servicos
- [ ] Smoke tests em producao passando
- [ ] Gateway proxy: latencia adicionada dentro do SLO (< 50ms overhead)
- [ ] WebSocket connections do dashboard reconectando corretamente

## Pos-Deploy
- [ ] Metricas de producao dentro dos SLOs (latencia p95, throughput, error rate)
- [ ] Sem aumento de error rate nos ultimos 30 minutos
- [ ] Sem degradacao de latencia no gateway proxy
- [ ] Logs sem erros inesperados (verificar structured logs com correlation ID)
- [ ] Traces distribuidos funcionando ponta a ponta (OpenTelemetry)
- [ ] Alertas Grafana configurados e funcionando para novas metricas
- [ ] Feature flags ativadas gradualmente (se aplicavel): 10% -> 25% -> 50% -> 100%
- [ ] Multi-tenancy: isolamento validado em producao (spot check)
- [ ] Stakeholders notificados do sucesso do deploy
- [ ] Metricas de custo de tokens sendo coletadas corretamente (se modulo de billing afetado)

## Rollback Triggers
Se qualquer um dos criterios abaixo for observado, executar rollback imediato:
- Error rate > 1% por mais de 5 minutos
- Latencia p95 do gateway > 500ms (excluindo tempo de LLM)
- Perda de dados de analytics (eventos nao chegando ao ClickHouse)
- Falha de isolamento multi-tenant detectada
- Health check falhando em mais de 1 instancia
