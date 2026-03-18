# Testing Strategy Template

## Pirâmide de Testes
- **Unit Tests (70%)**: Lógica de negócio isolada, sem I/O externo
- **Integration Tests (20%)**: Interação entre componentes, DB, APIs externas
- **E2E Tests (10%)**: Fluxos completos do usuário, browser automation

## Ferramentas (configurável por projeto)
- Unit: Jest/Vitest (JS) | pytest (Python) | JUnit (Java)
- Integration: Supertest (API) | Testcontainers (DB)
- E2E: Playwright | Cypress
- Performance: k6 | Artillery
- Security: OWASP ZAP | Snyk

## Cobertura Mínima
- Código novo: 80%
- Código crítico (auth, pagamento, dados sensíveis): 95%
- Código legado em mudança: cobertura deve aumentar, nunca diminuir

## Ambientes de Teste
- Local: testes unitários e integração com mocks
- CI: todos os testes automatizados
- Staging: E2E e performance tests
- Produção: smoke tests e synthetic monitoring

## Dados de Teste
- Factories/Fixtures para dados consistentes
- Nunca usar dados reais de produção em testes
- Cleanup automático após cada teste
- Seeds versionados para cenários complexos
