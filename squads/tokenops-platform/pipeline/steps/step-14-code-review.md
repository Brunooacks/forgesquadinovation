---
step: "14"
name: "Code Review"
type: code_review
agent: tech-lead
tasks:
  - review-code
depends_on: step-13
on_reject: step-09
max_review_cycles: 3
phase: review
---

# Step 14: Code Review

## Para o Pipeline Runner

O Tech Lead executa a revisao de codigo de todos os modulos MVP. O Pipeline Runner deve invocar o agente tech-lead com a task review-code. Se o review resultar em rejeicao, o Pipeline Runner deve retornar ao step-09 (implementacao) com o feedback do Tech Lead. O ciclo de review pode se repetir ate 3 vezes (max_review_cycles). Se apos 3 ciclos ainda houver issues criticas, escalar para o Architect.

### Criterios de revisao:

1. **NestJS Best Practices**:
   - Uso correto de modules, controllers, services, providers
   - Injecao de dependencia via constructor
   - Decorators apropriados (@Injectable, @Controller, @Module)
   - Guards e interceptors para cross-cutting concerns
   - Exception filters para tratamento padronizado de erros

2. **TypeScript Strict Compliance**:
   - strict mode habilitado no tsconfig.json
   - Sem uso de `any` (exceto em boundaries com APIs externas, devidamente justificado)
   - Interfaces e types para todos os contratos
   - Enums para valores constantes
   - Generics onde aplicavel

3. **Adapter Pattern — Corretude**:
   - Todos os LLM providers acessados exclusivamente via adapters
   - Nenhuma chamada direta a SDKs de providers fora dos adapters
   - Interface LLMAdapter implementada corretamente por todos os 7 adapters
   - Factory pattern para selecao de adapter por provider

4. **Seguranca**:
   - API keys armazenadas de forma segura (encrypted at rest)
   - Input validation em todos os endpoints (class-validator + DTOs)
   - Rate limiting por tenant e por API key
   - CORS configurado corretamente
   - Sem secrets em codigo ou logs
   - SQL injection prevention (parameterized queries)

5. **Tratamento de Erros**:
   - Error handling consistente em todos os modulos
   - Retry logic com exponential backoff para chamadas a LLM providers
   - Circuit breaker para providers instáveis
   - Logging estruturado com correlation IDs
   - Graceful degradation quando um provider falha

6. **Cobertura de Testes**:
   - Cobertura >= 80% em todos os modulos MVP
   - Testes unitarios, integracao e E2E presentes
   - Mocks apropriados para dependencias externas (LLM providers, databases)

7. **Performance**:
   - Sem regressoes de performance identificadas nos testes do step-13
   - Queries otimizadas (indices, pagination)
   - Async operations onde aplicavel (analytics writes)
   - Connection pooling configurado

### Fluxo de rejeicao:

Se issues criticas forem encontradas:
1. Tech Lead documenta issues no code-review-report.md
2. Pipeline Runner retorna ao step-09 com feedback
3. Desenvolvedores corrigem os issues
4. Pipeline Runner re-executa steps 10-13
5. Novo ciclo de code review (max 3 ciclos)

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Backend source code | `output/implementation/` | Codigo-fonte dos modulos backend |
| Frontend source code | `output/implementation/` | Codigo-fonte das paginas frontend |
| Test report | `output/quality/test-report.md` | Resultados dos testes automatizados |
| Performance report | `output/quality/performance-report.md` | Resultados dos testes de performance |
| Architecture doc | `output/architecture/architecture-document.md` | Arquitetura de referencia |
| API contracts | `output/architecture/api-contracts.md` | Contratos de API |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Code Review Report | `output/review/code-review-report.md` | Relatorio de code review com findings, severidade e recomendacoes |

### Estrutura do code-review-report.md

```
# TokenOps Platform — Code Review Report
## 1. Resumo Executivo
## 2. Ciclo de Review (N de max_review_cycles)
## 3. Findings por Modulo
### 3.1 Gateway
### 3.2 Token Estimator
### 3.3 Model Recommendation Engine
### 3.4 Frontend (Dashboard, Estimator UI, Recommendation UI)
### 3.5 Shared Services (Auth, Analytics, Cache)
## 4. Findings por Categoria
### 4.1 NestJS Best Practices
### 4.2 TypeScript Compliance
### 4.3 Adapter Pattern
### 4.4 Seguranca
### 4.5 Error Handling
### 4.6 Performance
## 5. Cobertura de Testes
## 6. Decisao: Aprovado / Rejeitado
## 7. Feedback para Desenvolvedores (se rejeitado)
```

## Execution Mode

- **Tipo**: Code Review (automatizado com possibilidade de loop)
- **Agente**: tech-lead
- **Tasks**: review-code
- **on_reject**: Retorna ao step-09 com feedback
- **max_review_cycles**: 3
- **Automatizavel**: Sim — execucao pelo agente com criterios definidos
- **Tempo estimado**: 2-3 horas por ciclo de review

## Quality Gate

- [ ] Todos os modulos MVP revisados
- [ ] Zero findings de severidade critica (blocker)
- [ ] NestJS best practices seguidas
- [ ] TypeScript strict mode sem violacoes
- [ ] Adapter pattern implementado corretamente (sem chamadas diretas a providers)
- [ ] Seguranca validada (API keys, input validation, rate limiting)
- [ ] Tratamento de erros consistente
- [ ] Cobertura de testes >= 80%
- [ ] Sem regressoes de performance
- [ ] Relatorio code-review-report.md gerado com decisao final (aprovado/rejeitado)
