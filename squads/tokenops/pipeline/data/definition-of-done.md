# Definition of Done (DoD) — TokenOps

Uma user story so e considerada "Done" quando TODOS os criterios abaixo sao atendidos:

## Codigo
- [ ] Codigo implementado e commitado no branch da feature
- [ ] Code review aprovado por pelo menos 1 revisor (Tech Lead ou Arquiteto)
- [ ] Sem warnings do linter (ESLint) ou do compilador TypeScript (strict mode)
- [ ] Sem vulnerabilidades criticas no SonarQube ou Snyk
- [ ] Path aliases e barrel exports seguindo o padrao do projeto

## Testes
- [ ] Testes unitarios escritos e passando (cobertura >= 80% no codigo novo)
- [ ] Codigo critico (gateway, estimator, billing, auth) com cobertura >= 95%
- [ ] Testes de integracao passando (incluindo Testcontainers para DB)
- [ ] Testes E2E para fluxos criticos passando (Playwright)
- [ ] Testes de regressao executados sem falhas
- [ ] Testes de performance validados para modulos do gateway proxy

## Documentacao
- [ ] API documentada (OpenAPI/Swagger spec atualizada)
- [ ] README do modulo atualizado se necessario
- [ ] ADR criado para decisoes arquiteturais significativas
- [ ] Release notes atualizadas
- [ ] Storybook atualizado para componentes UI novos ou alterados

## Observabilidade
- [ ] Traces OpenTelemetry configurados para novos endpoints/servicos
- [ ] Metricas Prometheus expostas para operacoes criticas
- [ ] Logs estruturados (JSON) com correlation ID implementados
- [ ] Dashboards Grafana atualizados se novas metricas foram adicionadas
- [ ] Alertas configurados para SLOs relevantes

## Multi-Tenancy
- [ ] Isolamento de dados por organization_id validado
- [ ] Row-level security testado (tenant A nao acessa dados de tenant B)
- [ ] Rate limiting por organizacao configurado (se aplicavel)

## Deploy
- [ ] Build de CI passando (lint + type-check + tests + security)
- [ ] Deploy em staging executado com sucesso
- [ ] Smoke tests passando em staging
- [ ] Migrations de banco testadas em staging (PostgreSQL e ClickHouse)
- [ ] Runbook atualizado se necessario

## Qualidade
- [ ] Criterios de aceite da user story verificados
- [ ] Sem bugs conhecidos de severidade alta ou critica
- [ ] Performance dentro dos SLOs definidos (p95 latencia, throughput)
- [ ] Acessibilidade validada (WCAG 2.1 AA) para componentes de dashboard
- [ ] Feature flags configuradas para rollout gradual (se aplicavel)
