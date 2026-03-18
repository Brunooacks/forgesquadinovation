# Coding Standards

## Gerais
- Nomes descritivos para variáveis, funções e classes — o código deve ser auto-documentável
- Funções curtas (max 30 linhas) com responsabilidade única
- Sem magic numbers — usar constantes nomeadas
- Sem código comentado — usar version control
- DRY com bom senso — 3 repetições justificam abstração, 2 não

## Git
- Commits semânticos: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- Branch naming: `feature/`, `bugfix/`, `hotfix/`, `release/`
- PRs com descrição clara do que, porquê e como testar
- Max 400 linhas por PR

## Backend
- API-first: OpenAPI spec antes de implementar
- Input validation em toda boundary (controllers, handlers)
- Error handling explícito — nunca silenciar exceções
- Structured logging (JSON) com correlation ID
- Migrations versionadas e imutáveis

## Frontend
- Component-based architecture
- Separação de presentational vs container components
- CSS modules ou styled-components — sem CSS global
- Lazy loading para rotas e componentes pesados
- Acessibilidade (WCAG 2.1 AA) como requisito

## Testes
- Naming: `should_[expected]_when_[condition]`
- Arrange-Act-Assert pattern
- Sem dependência entre testes
- Mocks apenas para boundaries externas
