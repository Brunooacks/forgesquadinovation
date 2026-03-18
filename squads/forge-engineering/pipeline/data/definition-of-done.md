# Definition of Done (DoD)

Uma user story só é considerada "Done" quando TODOS os critérios abaixo são atendidos:

## Código
- [ ] Código implementado e commitado no branch da feature
- [ ] Code review aprovado por pelo menos 1 revisor (Tech Lead ou Arquiteto)
- [ ] Sem warnings do linter ou do compilador
- [ ] Sem vulnerabilidades críticas no SonarQube

## Testes
- [ ] Testes unitários escritos e passando (cobertura >= 80% no código novo)
- [ ] Testes de integração passando
- [ ] Testes E2E para fluxos críticos passando
- [ ] Testes de regressão executados sem falhas

## Documentação
- [ ] API documentada (OpenAPI spec atualizada)
- [ ] README atualizado se necessário
- [ ] ADR criado para decisões arquiteturais significativas
- [ ] Release notes atualizadas

## Deploy
- [ ] Build de CI passando
- [ ] Deploy em staging executado com sucesso
- [ ] Smoke tests passando em staging
- [ ] Runbook atualizado se necessário

## Qualidade
- [ ] Critérios de aceite da user story verificados
- [ ] Sem bugs conhecidos de severidade alta ou crítica
- [ ] Performance dentro dos SLOs definidos
- [ ] Acessibilidade validada (WCAG 2.1 AA)
