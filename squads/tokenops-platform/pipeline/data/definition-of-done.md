# Definition of Done — TokenOps Platform

Uma story ou task so e considerada **Done** quando TODOS os criterios abaixo forem atendidos.

## Checklist

### Qualidade de Codigo
- [ ] Codigo compila sem erros (`tsc --noEmit` passa em modo strict)
- [ ] Zero uso de `any` ou `@ts-ignore` no codigo novo
- [ ] ESLint e Prettier passam sem warnings
- [ ] Codigo segue os padroes definidos em `coding-standards.md`

### Testes
- [ ] Testes unitarios escritos e passando (Jest)
- [ ] Cobertura >= 80% para codigo novo (90% para modulos criticos: Gateway, Estimator)
- [ ] Testes de integracao para novos endpoints ou queries de banco
- [ ] Testes E2E atualizados se o fluxo do usuario foi alterado

### Code Review
- [ ] Code review aprovado pelo Tech Lead
- [ ] Conformidade arquitetural verificada pelo Architect
- [ ] Nenhum comentario de review aberto ou pendente
- [ ] PR passa em todos os checks de CI (lint, types, tests, coverage)

### Documentacao
- [ ] Endpoints de API documentados (OpenAPI/Swagger com exemplos)
- [ ] Documentacao atualizada se mudanca e visivel ao usuario
- [ ] ADR (Architecture Decision Record) criado para decisoes arquiteturais significativas
- [ ] Changelog atualizado com descricao da mudanca

### Error Handling
- [ ] Tratamento de erro implementado (custom exceptions no NestJS, error boundaries no React)
- [ ] Erros logados com trace ID para correlacao (OpenTelemetry)
- [ ] Respostas de erro seguem formato padrao: `{ statusCode, message, error, timestamp, path }`
- [ ] Nenhum stack trace exposto em respostas de producao

### Performance
- [ ] Budget de performance atendido (sem regressao de latencia no Gateway)
- [ ] Nenhuma query N+1 introduzida
- [ ] Queries ao ClickHouse filtram por `org_id` e periodo
- [ ] Componentes pesados do frontend usam dynamic import

### Seguranca
- [ ] Nenhum secret no codigo (API keys, senhas, tokens)
- [ ] Validacao de input em todos os endpoints (class-validator)
- [ ] Isolamento multi-tenant verificado (RLS no PostgreSQL, filtro por org_id)
- [ ] Dependencias escaneadas (sem vulnerabilidades criticas conhecidas)

### Deploy
- [ ] Feature branch com squash merge para `main`
- [ ] Commit message segue conventional commits
- [ ] Pipeline de CI/CD verde
- [ ] Migracao de banco testada (PostgreSQL e/ou ClickHouse)

## Notas

- Se qualquer item nao se aplica a uma story especifica, o Tech Lead deve aprovar a excecao explicitamente
- Stories que alteram o Gateway ou Estimator requerem aprovacao adicional do Architect
- Performance tests (k6) sao obrigatorios para mudancas no Gateway
