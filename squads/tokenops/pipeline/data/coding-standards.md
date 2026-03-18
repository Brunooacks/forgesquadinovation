# Coding Standards — TokenOps

## Gerais
- Nomes descritivos para variaveis, funcoes e classes — o codigo deve ser auto-documentavel
- Funcoes curtas (max 30 linhas) com responsabilidade unica
- Sem magic numbers — usar constantes nomeadas
- Sem codigo comentado — usar version control
- DRY com bom senso — 3 repeticoes justificam abstracao, 2 nao
- Preferir composicao sobre heranca
- Imutabilidade por padrao — usar `readonly`, `const`, `as const`

## TypeScript
- Strict mode habilitado (`strict: true` no tsconfig)
- Nunca usar `any` — usar `unknown` e type guards quando necessario
- Interfaces para contratos publicos, types para unions/intersections
- Enums apenas como `const enum` ou string literal unions
- Generics com constraints: `<T extends BaseEntity>` em vez de `<T>`
- Barrel exports (`index.ts`) apenas em modulos publicos
- Path aliases configurados: `@modules/`, `@common/`, `@config/`, `@shared/`

## NestJS (Backend)
- API-first: OpenAPI spec (Swagger) antes de implementar
- Um modulo por dominio de negocio (gateway, estimator, recommendation, optimization, remediation, dashboard)
- DTOs com `class-validator` e `class-transformer` para input validation
- Custom exceptions extendendo `HttpException` com error codes padronizados
- Guards para autenticacao, Interceptors para logging/metrics, Pipes para transformacao
- Repository pattern para acesso a dados — nunca injetar ORM direto nos services
- Structured logging (JSON) com correlation ID via `cls-hooked` ou `AsyncLocalStorage`
- Migrations versionadas e imutaveis (TypeORM ou Prisma)
- Config module com validacao de env vars via Joi/Zod no startup

## Next.js + React (Frontend)
- App Router (Next.js 14+) com Server Components por padrao
- Client Components apenas quando necessario (`'use client'` explicito)
- Separacao de presentational vs container components
- Tailwind CSS com design tokens customizados — sem CSS global ou inline styles arbitrarios
- Componentes reutilizaveis em `@/components/ui/` seguindo padroes do shadcn/ui
- Lazy loading para rotas e componentes pesados via `dynamic()` e `Suspense`
- React Query (TanStack Query) para server state management
- Zustand ou Context API para client state — sem prop drilling
- Acessibilidade (WCAG 2.1 AA) como requisito em todos os componentes
- Internacionalizacao (i18n) preparada desde o inicio

## Dados e Analytics
- PostgreSQL: queries tipadas via Prisma ou TypeORM com query builder
- ClickHouse: queries de analytics isoladas em repositorios dedicados
- Redis: prefixo de namespace por dominio (`tokenops:cache:`, `tokenops:session:`, `tokenops:queue:`)
- Nunca armazenar PII sem criptografia — campos sensiveis encriptados at rest
- Indices planejados com o Arquiteto antes de criar — evitar over-indexing

## Git
- Commits semanticos: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- Escopo obrigatorio: `feat(gateway):`, `fix(estimator):`, `refactor(dashboard):`
- Branch naming: `feature/`, `bugfix/`, `hotfix/`, `release/`
- PRs com descricao clara do que, porque e como testar
- Max 400 linhas por PR — PRs maiores devem ser divididos
- Squash merge para features, merge commit para releases

## Testes
- Naming: `should_[expected]_when_[condition]`
- Arrange-Act-Assert pattern
- Sem dependencia entre testes
- Mocks apenas para boundaries externas (APIs de LLM providers, servicos de billing)
- Factories com `@faker-js/faker` para dados de teste
- Testes de token estimation devem usar fixtures com prompts reais anonimizados
