# Testing Strategy — TokenOps

## Piramide de Testes
- **Unit Tests (70%)**: Logica de negocio isolada, sem I/O externo
- **Integration Tests (20%)**: Interacao entre componentes, DB, APIs externas
- **E2E Tests (10%)**: Fluxos completos do usuario, browser automation

## Ferramentas

### Backend (NestJS)
| Tipo | Ferramenta |
|------|-----------|
| Unit | Jest + ts-jest |
| Integration | Supertest + Testcontainers (PostgreSQL, ClickHouse, Redis) |
| Mocking | jest.mock, nock (HTTP), ioredis-mock (Redis) |
| Fixtures | @faker-js/faker + custom factories |

### Frontend (Next.js + React)
| Tipo | Ferramenta |
|------|-----------|
| Unit | Vitest + React Testing Library |
| Component | Storybook + Chromatic (visual regression) |
| E2E | Playwright |

### Performance e Seguranca
| Tipo | Ferramenta |
|------|-----------|
| Load Testing | k6 (gateway proxy throughput, dashboard concurrent users) |
| Performance | Artillery (API latency benchmarks) |
| Security | OWASP ZAP (DAST), Snyk (SCA), ESLint security plugins |

## Cobertura Minima
- Codigo novo: 80%
- Codigo critico (gateway proxy, token estimation, billing, auth): 95%
- Codigo legado em mudanca: cobertura deve aumentar, nunca diminuir
- Threshold configurado no CI — build falha se cobertura cair

## Testes por Modulo

### AI Gateway Proxy
- Unit: logica de roteamento, rate limiting, circuit breaker state machine
- Integration: proxy request/response com mock de LLM providers (nock)
- Load: throughput sob carga (1000+ req/s), latencia adicionada pelo proxy (< 50ms overhead)
- Chaos: fallback para provider alternativo quando primario falha

### Token Estimator
- Unit: algoritmos de tokenizacao por modelo (GPT, Claude, Gemini, etc.)
- Integration: estimativa vs consumo real (delta < 5% para modelos suportados)
- Fixtures: prompts anonimizados de diferentes tamanhos e complexidades
- Benchmark: performance de estimativa (< 10ms por request)

### Model Recommendation
- Unit: algoritmo de scoring (custo, qualidade, latencia), ranking
- Integration: recomendacao com dados historicos de uso reais
- A/B: framework para testar diferentes estrategias de recomendacao

### Prompt Optimization
- Unit: regras de otimizacao, sugestoes de reducao
- Integration: otimizacao aplicada + re-estimativa de tokens
- Quality: output quality nao degrada apos otimizacao (avaliacao por LLM judge)

### Remediation Engine
- Unit: logica de triggers, thresholds, acoes
- Integration: trigger de alerta quando limite e atingido
- E2E: fluxo completo de deteccao -> alerta -> acao automatica

### Dashboard
- Component: componentes de graficos, tabelas, filtros com Storybook
- E2E (Playwright): fluxos de login, navegacao, filtros, export de dados
- Visual regression: Chromatic para detectar mudancas visuais indesejadas
- Accessibility: axe-core integrado nos testes de componente

## Ambientes de Teste
| Ambiente | Testes | Dados |
|----------|--------|-------|
| Local | Unit + Integration (Testcontainers) | Factories + Seeds |
| CI (GitHub Actions) | Unit + Integration + Lint + Security | Testcontainers + Fixtures |
| Staging | E2E + Performance + Smoke | Dados sinteticos realistas |
| Producao | Smoke tests + Synthetic monitoring | Requests sinteticos |

## Dados de Teste
- Factories com `@faker-js/faker` para dados consistentes
- Nunca usar dados reais de producao em testes
- Cleanup automatico apos cada teste (transactions rollback)
- Seeds versionados para cenarios complexos de analytics
- Fixtures de prompts anonimizados para testes de token estimation
- Mock responses de LLM providers para testes deterministicos

## CI/CD Integration
- Pre-commit: lint + type-check + unit tests afetados
- PR: full unit + integration + security scan
- Merge to main: full suite + E2E em staging
- Release: full suite + performance tests + smoke em producao
- Quality gates: build falha se qualquer threshold nao for atingido
