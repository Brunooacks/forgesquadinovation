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

# Step 14: Tech Lead — Code Review TokenOps

## Para o Pipeline Runner

Acione o agente `tech-lead` com a task `review-code`. O Tech Lead conduz uma
revisao de codigo completa do TokenOps cobrindo qualidade, padroes NestJS/Next.js,
seguranca do Gateway proxy, e manutenibilidade. Se o codigo for rejeitado,
retorne ao Step 09.

### Comportamento de Rejeicao:

- **on_reject:** Retorna ao `step-09` para correcoes.
- **max_review_cycles:** 3 ciclos de revisao. Se apos 3 ciclos ainda houver
  problemas criticos, escale para o usuario via checkpoint.
- Cada ciclo de revisao deve ter feedback especifico e acionavel.

### Instrucoes para o Agente:

1. **Revise** todo o codigo implementado (backend NestJS + frontend Next.js).
2. **Avalie** cada dimensao de qualidade:

   **a) Corretude:**
   - Logica de token counting esta correta para cada modelo?
   - Cost calculation esta preciso (input_tokens * price + output_tokens * price)?
   - Routing logic do Gateway trata todos os edge cases?
   - Circuit breaker implementado corretamente (estados: closed, open, half-open)?
   - Rate limiting conta corretamente por tenant/API key?
   - Streaming responses (SSE) tratados sem memory leaks?

   **b) Padroes NestJS:**
   - Modulos NestJS bem organizados (gateway, estimation, recommendation, cost, dashboard)?
   - Injecao de dependencia correta?
   - Guards e interceptors para auth e logging?
   - DTOs com class-validator para validacao?
   - Exception filters para tratamento padronizado de erros?
   - Nomenclatura consistente (services, controllers, repositories)?

   **c) Padroes Next.js:**
   - App Router com server/client components corretos?
   - Data fetching com React Query bem implementado?
   - Componentes UI reutilizaveis e compostos?
   - Tailwind CSS consistente com design system?
   - SEO e meta tags configurados?

   **d) Seguranca:**
   - API key validation em todos os endpoints do Gateway?
   - Tenant isolation (nao ha data leakage entre tenants)?
   - Input validation em todas as entradas (DTOs)?
   - Protecao contra injection (SQL, NoSQL)?
   - Rate limiting protege contra abuse?
   - Segredos nao hardcoded?
   - CORS configurado corretamente?

   **e) Performance:**
   - Gateway hot path otimizado (minimo de alocacoes)?
   - Token counting nao bloqueia o event loop?
   - Async logging (nao bloqueia response)?
   - ClickHouse queries otimizadas (indices, materialized views)?
   - Redis operations com pipeline/batch quando possivel?
   - Frontend: bundle size adequado? Code splitting?

   **f) Manutenibilidade:**
   - Codigo legivel e auto-documentado?
   - Complexidade ciclomatica aceitavel?
   - Testes adequados e manuteníveis?
   - LLM provider adapters faceis de estender (novo provider)?

   **g) Observabilidade:**
   - OpenTelemetry traces no fluxo completo do Gateway?
   - Prometheus metricas para latencia, throughput, errors?
   - Logging estruturado com correlation IDs?
   - Health check endpoints com detalhes de dependencias?

3. **Classifique** cada finding:
   - **Blocker:** Deve ser corrigido antes de prosseguir.
   - **Major:** Deve ser corrigido, mas pode ser em paralelo.
   - **Minor:** Sugestao de melhoria, nao bloqueia.
   - **Info:** Observacao educativa.

4. **Emita** um veredito: APROVADO, APROVADO COM RESSALVAS, ou REJEITADO.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Backend Code | `output/implementation/backend/` | Codigo NestJS |
| Frontend Code | `output/implementation/frontend/` | Codigo Next.js |
| Architecture Design | `output/architecture/architecture-design.md` | Padroes a seguir |
| ADRs | `output/architecture/adrs/` | Decisoes arquiteturais |
| Test Report | `output/quality/test-report.md` | Resultados de testes |
| Performance Report | `output/quality/performance-report.md` | Resultados de performance |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Code Review Report | `output/review/code-review-report.md` | Relatorio detalhado do review |

### Estrutura do code-review-report.md:

```markdown
# Code Review Report — TokenOps

## Veredito: [APROVADO / APROVADO COM RESSALVAS / REJEITADO]
- **Ciclo de revisao:** [N de max_review_cycles]
- **Data:** [data]
- **Revisor:** tech-lead

## Resumo
- **Blockers:** [N]
- **Majors:** [N]
- **Minors:** [N]
- **Info:** [N]

## Findings por Modulo

### AI Gateway Proxy
| ID | Arquivo | Linha | Severidade | Descricao | Sugestao |
|----|---------|-------|-----------|-----------|----------|
| CR-001 | [path] | [L] | Blocker | [problema] | [solucao] |

### Token Estimation Engine
...

### Model Recommendation Engine
...

### Cost Engine
...

### Dashboard (Frontend)
...

### Platform
...

## Metricas de Qualidade
| Metrica | Valor | Status |
|---------|-------|--------|
| Complexidade ciclomatica max | [N] | OK/NOK |
| Duplicacao de codigo | [X%] | OK/NOK |
| Cobertura de testes | [X%] | OK/NOK |
| Gateway overhead p99 | [X]ms | OK/NOK |
| Token Estimation accuracy | [X%] | OK/NOK |

## Observacoes Gerais
[Comentarios do revisor sobre qualidade geral, padroes NestJS/Next.js]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `tech-lead`
- **Skills:** `review-code`
- **Timeout:** 45 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 15, verifique:

- [ ] Todos os modulos de codigo revisados (Gateway, Estimation, Recommendation, Cost, Dashboard, Platform)
- [ ] Zero blockers pendentes
- [ ] Majors corrigidos ou aceitos com justificativa
- [ ] Seguranca do Gateway validada (tenant isolation, rate limiting, input validation)
- [ ] Padroes NestJS e Next.js respeitados
- [ ] Veredito emitido: APROVADO ou APROVADO COM RESSALVAS
- [ ] Relatorio de review gerado
- [ ] Numero de ciclos dentro do limite (max 3)
