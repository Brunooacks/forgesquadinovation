---
step: "15"
name: "Revisao Arquitetural do Codigo"
type: agent
agent: architect
tasks:
  - review-architecture
depends_on: step-14
phase: review
---

# Step 15: Architect — Revisao Arquitetural do Codigo TokenOps

## Para o Pipeline Runner

Acione o agente `architect` com a task `review-architecture`. O Arquiteto
verifica se o codigo implementado do TokenOps segue fielmente a arquitetura
definida, com atencao especial ao design do AI Gateway proxy, separacao de
engines e integracao com ClickHouse para analytics.

### Instrucoes para o Agente:

1. **Leia** a arquitetura definida e todas as ADRs.
2. **Compare** a implementacao com o design:

   **a) Conformidade Estrutural:**
   - AI Gateway modulo separado dos demais?
   - Token Estimation Engine como servico independente?
   - Model Recommendation Engine desacoplado?
   - Cost Engine centralizado e reutilizavel?
   - Analytics pipeline assincrona (nao bloqueia Gateway)?
   - Camadas de abstracao corretas (controller -> service -> repository)?
   - Dependencias entre modulos conforme planejado?

   **b) Conformidade com ADRs:**
   - ADR-001: Gateway como proxy reverso implementado corretamente?
   - ADR-002: ClickHouse para analytics com schema correto?
   - ADR-003: Token counting conforme estrategia definida?
   - ADR-004: Multi-tenancy conforme modelo escolhido?
   - ADR-005: Caching conforme estrategia definida?
   - Novas decisoes foram tomadas sem ADR?

   **c) Contratos de API:**
   - Gateway API compativel com formato OpenAI?
   - Dashboard API endpoints conforme especificacao?
   - Token Estimation API com request/response corretos?
   - Model Recommendation API com ranking format correto?
   - Versionamento de API implementado?
   - Codigos de erro padronizados?

   **d) Modelagem de Dados:**
   - PostgreSQL: entidades conforme diagrama ER?
   - ClickHouse: schema otimizado para time-series queries?
   - Redis: estruturas de dados adequadas (rate limiting, caching)?
   - Migrations reversiveis?
   - Indices adequados para queries do Dashboard?

   **e) Requisitos Nao-Funcionais:**
   - Escalabilidade: Gateway pode escalar horizontalmente?
   - Seguranca: multi-tenancy com isolamento correto?
   - Observabilidade: OpenTelemetry no fluxo completo do Gateway?
   - Resiliencia: circuit breaker, retry, fallback implementados?
   - Performance: Gateway hot path otimizado?

   **f) Divida Tecnica:**
   - Identificar divida tecnica introduzida.
   - Classificar por prioridade.
   - Documentar impacto nos modulos pos-MVP (Cost Explorer, Alerts & Budgets).

3. **Emita** veredito arquitetural: CONFORME, PARCIALMENTE CONFORME, NAO CONFORME.

### Regras:

- Desvios da arquitetura devem ser justificados com nova ADR.
- Se NAO CONFORME, retorne ao Step 09 com instrucoes de correcao.
- Divida tecnica aceitavel deve ser documentada para resolucao futura.
- Verificar que a arquitetura suporta extensao para modulos pos-MVP.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Design original TokenOps |
| ADRs | `output/architecture/adrs/` | Decisoes arquiteturais |
| Backend Code | `output/implementation/backend/` | Codigo NestJS |
| Frontend Code | `output/implementation/frontend/` | Codigo Next.js |
| Code Review Report | `output/review/code-review-report.md` | Findings do Tech Lead |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Arch Review Report | `output/review/arch-review-report.md` | Relatorio de conformidade arquitetural |

### Estrutura do arch-review-report.md:

```markdown
# Revisao Arquitetural — TokenOps

## Veredito: [CONFORME / PARCIALMENTE CONFORME / NAO CONFORME]
- **Data:** [data]
- **Revisor:** architect

## Conformidade Estrutural
| Componente | Status | Observacao |
|-----------|--------|-----------|
| AI Gateway Proxy | Conforme | - |
| Token Estimation Engine | Conforme | - |
| Model Recommendation Engine | Conforme | - |
| Cost Engine | Conforme | - |
| Analytics Pipeline (ClickHouse) | Conforme | - |
| Dashboard API | Conforme | - |
| Platform (Multi-tenancy) | Conforme | - |

## Conformidade com ADRs
| ADR | Titulo | Status | Observacao |
|-----|--------|--------|-----------|
| ADR-001 | Gateway como proxy reverso | Implementada | - |
| ADR-002 | ClickHouse para analytics | Implementada | - |
| ADR-003 | Estrategia de token counting | Implementada | - |
| ADR-004 | Modelo de multi-tenancy | Implementada | - |
| ADR-005 | Estrategia de caching | Implementada | - |

## Contratos de API
[Validacao de conformidade por endpoint]

## Modelagem de Dados
[Validacao PostgreSQL, ClickHouse, Redis]

## Extensibilidade para Pos-MVP
| Modulo Futuro | Pronto para Extensao? | Observacao |
|--------------|----------------------|-----------|
| Cost Explorer | Sim/Nao | [detalhes] |
| Alerts & Budgets | Sim/Nao | [detalhes] |

## Divida Tecnica Identificada
| ID | Descricao | Prioridade | Impacto | Modulo |
|----|-----------|-----------|---------|--------|
| TD-001 | [descricao] | Alta | [impacto] | [modulo] |

## Recomendacoes
[Lista de acoes recomendadas]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `architect`
- **Skills:** `review-architecture`
- **Timeout:** 30 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 16, verifique:

- [ ] Todos os modulos verificados contra a arquitetura
- [ ] Conformidade com ADRs validada
- [ ] Contratos de API verificados (Gateway, Dashboard, Estimation, Recommendation)
- [ ] Modelagem de dados validada (PostgreSQL, ClickHouse, Redis)
- [ ] Extensibilidade para modulos pos-MVP verificada
- [ ] Veredito: CONFORME ou PARCIALMENTE CONFORME (com justificativa)
- [ ] Divida tecnica documentada
- [ ] Relatorio de revisao arquitetural gerado
