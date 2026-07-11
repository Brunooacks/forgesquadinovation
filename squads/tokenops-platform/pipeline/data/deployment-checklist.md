# Deployment Checklist — TokenOps Platform (SaaS)

## Pre-Deployment

### Qualidade
- [ ] Todos os testes passando (unit, integration, E2E)
- [ ] Cobertura de testes dentro do threshold (80% geral, 90% criticos)
- [ ] Performance budget atendido (k6 report sem regressao)
- [ ] Nenhuma vulnerabilidade critica em dependencias (`npm audit`)
- [ ] Code review aprovado e PR mergeado

### Documentacao
- [ ] Release notes preparadas com lista de mudancas
- [ ] API changelog atualizado (OpenAPI/Swagger)
- [ ] Runbook atualizado se procedimento operacional mudou
- [ ] Comunicacao ao time sobre o deploy planejado

### Seguranca
- [ ] Security review concluido
- [ ] Nenhum secret exposto no codigo ou logs
- [ ] SAST scan passou sem findings criticos
- [ ] Dependencias atualizadas (sem CVEs criticos)

---

## Infrastructure

### Build
- [ ] Docker images construidas e tagueadas (`git SHA` + `latest`)
- [ ] Images publicadas no container registry
- [ ] Multi-stage build otimizado (imagem final < 200MB)

### CI/CD
- [ ] Pipeline de CI/CD verde em todos os stages
- [ ] Artefatos de build versionados e rastreaveir
- [ ] Aprovacao manual no gate de producao (se aplicavel)

### Configuracao
- [ ] Environment variables configuradas para o ambiente alvo
- [ ] Secrets armazenados no vault (nunca em env files no repo)
- [ ] Feature flags configurados para novas funcionalidades
- [ ] Rate limits e quotas revisados para o ambiente

---

## Database

### PostgreSQL
- [ ] Migrações aplicadas com sucesso no ambiente alvo
- [ ] Migrações testadas em staging antes de producao
- [ ] Backup do banco realizado antes do deploy
- [ ] RLS policies verificadas para novas tabelas
- [ ] Indexes criados para novas queries

### ClickHouse
- [ ] Schemas atualizados (novas tabelas, colunas, materialized views)
- [ ] Particionamento verificado para novas tabelas
- [ ] Queries de agregacao testadas com volume realista
- [ ] Retention policies configuradas

### Redis
- [ ] Cache keys com TTL apropriado
- [ ] Cache warming executado para dados criticos (pricing models, provider configs)
- [ ] Rate limiting rules atualizadas se limites mudaram
- [ ] Verificar que chaves antigas incompativeis foram invalidadas

---

## Monitoring

### OpenTelemetry
- [ ] Tracing configurado para novos endpoints e servicos
- [ ] Trace context propagado entre Gateway e providers
- [ ] Sampling rate adequado (100% para erros, 10% para sucesso em producao)
- [ ] Custom spans para operacoes criticas (estimation, routing, cache lookup)

### Prometheus
- [ ] Metricas customizadas expostas para novas funcionalidades
- [ ] Scrape targets atualizados para novos servicos
- [ ] Histogramas de latencia para novos endpoints
- [ ] Contadores de erro por tipo e modulo

### Grafana
- [ ] Dashboards operacionais atualizados (latencia, throughput, error rate)
- [ ] Dashboards de negocio atualizados (token usage, cost savings, provider distribution)
- [ ] Paineis para novas funcionalidades adicionados

### Alerting
- [ ] Alertas configurados para SLA (latencia p99 > 100ms, error rate > 1%)
- [ ] Alertas de budget (custo diario acima do threshold)
- [ ] Alertas de infraestrutura (CPU, memoria, disco, conexoes de banco)
- [ ] Canais de notificacao testados (Slack, PagerDuty, email)

---

## Deployment

### Estrategia
- [ ] Estrategia definida: blue-green ou canary
- [ ] Canary: porcentagem inicial definida (ex: 5% do trafego)
- [ ] Canary: criterios de promocao definidos (error rate < 0.1%, latencia estavel)
- [ ] Blue-green: ambiente idle preparado e verificado

### Health Checks
- [ ] Liveness probe respondendo (`/health/live`)
- [ ] Readiness probe respondendo (`/health/ready`)
- [ ] Startup probe configurado para cold start (aguardar conexoes de banco)
- [ ] Health check inclui verificacao de dependencias (PostgreSQL, ClickHouse, Redis)

### Smoke Tests
- [ ] Proxy request end-to-end com mock provider
- [ ] Estimation endpoint retornando resultado correto
- [ ] Dashboard carregando com dados reais
- [ ] WebSocket conectando e recebendo updates
- [ ] API key creation e authentication funcionando

---

## Post-Deployment

### Verificacao Imediata (primeiros 15 minutos)
- [ ] Monitoramento verificado — dashboards mostrando trafego
- [ ] Error rates dentro do esperado (< 0.1%)
- [ ] Latencia dentro do budget (Gateway p95 < 50ms)
- [ ] Logs sem erros inesperados
- [ ] Nenhum alerta disparado

### Validacao de Fluxos (primeiros 30 minutos)
- [ ] Fluxo de proxy: request → Gateway → Provider → Response funcional
- [ ] Fluxo de estimation: prompt → Estimator → resultado com custo
- [ ] Fluxo de recommendation: request → Recommender → modelo sugerido
- [ ] Dashboard exibindo metricas atualizadas em tempo real
- [ ] Multi-tenancy: dados isolados entre organizacoes

### Comunicacao
- [ ] Time notificado sobre deploy concluido
- [ ] Status page atualizado (se aplicavel)
- [ ] Release notes publicadas

---

## Rollback

### Preparacao
- [ ] Procedimento de rollback documentado e testado
- [ ] Versao anterior tagueada e imagem disponivel no registry
- [ ] Scripts de rollback de banco testados (down migrations)
- [ ] Tempo estimado de rollback documentado (alvo: < 5 minutos)

### Criterios de Rollback
- [ ] Error rate > 1% por mais de 5 minutos
- [ ] Latencia p95 > 200ms por mais de 5 minutos
- [ ] Funcionalidade critica indisponivel (proxy, estimation)
- [ ] Perda de dados detectada
- [ ] Alerta de seguranca critico

### Procedimento
1. Notificar o time no canal de incidentes
2. Reverter deploy para versao anterior (imagem tagueada)
3. Executar rollback de migrações de banco se necessario
4. Verificar health checks e smoke tests
5. Monitorar por 15 minutos apos rollback
6. Documentar incidente e causa raiz
7. Criar post-mortem se impacto ao usuario
