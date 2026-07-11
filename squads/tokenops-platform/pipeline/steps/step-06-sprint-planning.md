---
step: "06"
name: "Sprint Planning — MVP"
type: agent
agent: tech-lead
tasks:
  - plan-sprint
depends_on: step-05
phase: planning
---

# Step 06: Sprint Planning — MVP

## Para o Pipeline Runner

O agente Tech Lead deve decompor o escopo MVP em sprints de 2 semanas, distribuindo as user stories aprovadas e considerando as dependencias tecnicas e a arquitetura definida. O planejamento cobre 3 meses (6 sprints) para entregar o MVP completo.

### Decomposicao em Sprints:

**Sprint 1 — Foundation (Semanas 1-2)**:
- Setup do projeto NestJS com estrutura modular
- Configuracao de PostgreSQL schemas (users, orgs, teams, projects, api_keys)
- Configuracao de ClickHouse schemas (prompt_logs, token_usage, cost_events)
- Setup de Redis (connection, basic caching)
- Interfaces dos LLM Adapters (contratos, tipos)
- Autenticacao basica (JWT)
- CI/CD pipeline setup
- Sprint Goal: Infraestrutura base funcional com schemas e auth

**Sprint 2 — AI Gateway Core (Semanas 3-4)**:
- AI Gateway proxy core (interceptacao de requests)
- Token counting middleware (pre e post-execution)
- Cost calculation engine (pricing tables por modelo)
- Primeiro LLM Adapter funcional (OpenAI)
- Segundo LLM Adapter (Anthropic)
- Event emission para analytics pipeline
- Sprint Goal: Gateway proxy funcional com 2 providers

**Sprint 3 — Token Estimator + Basic Dashboard (Semanas 5-6)**:
- Token Estimator engine (estimativa pre-execucao)
- Estimativa por modelo/provider
- Terceiro LLM Adapter (Gemini ou Azure OpenAI)
- Next.js project setup com App Router
- Dashboard basico: total tokens, custo total, custo por modelo
- API endpoints para dashboard data
- Sprint Goal: Estimativa funcional + dashboard basico

**Sprint 4 — Model Recommendation + Dashboard Completo (Semanas 7-8)**:
- Model Recommendation Engine (scoring algorithm)
- Fatores de scoring: complexidade, contexto, criticidade, latencia, custo
- Dashboard widgets completos: custo por projeto, top prompts caros, economia potencial
- Cost Explorer com filtros (team, project, model, periodo)
- Quarto e quinto LLM Adapters (providers restantes prioritarios)
- Sprint Goal: Recomendacao funcional + dashboard completo

**Sprint 5 — Integration + Performance (Semanas 9-10)**:
- Integracao end-to-end de todos os modulos MVP
- Sexto e setimo LLM Adapters (providers restantes)
- Performance tuning (proxy latency, throughput)
- Load testing (k6) para validar 10k+ req/s
- Settings UI (org management, API keys, team management)
- Multi-tenancy hardening
- Sprint Goal: Sistema integrado com performance validada

**Sprint 6 — Polish + Deploy (Semanas 11-12)**:
- Bug fixes e polish
- Documentacao tecnica e API docs (OpenAPI)
- Onboarding flow para novos usuarios
- Billing integration (Stripe) para 3 planos
- Deployment preparation (Docker, infra)
- Smoke tests em ambiente de staging
- Sprint Goal: MVP pronto para deploy

### Estimativas:

- Capacidade estimada por sprint: definir com base no tamanho da equipe
- Velocity target: ajustar apos Sprint 1
- Buffer de contingencia: 15-20% por sprint

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| User Stories | `output/requirements/user-stories.md` | Stories priorizadas para distribuir nos sprints |
| Architecture Design | `output/architecture/architecture-design.md` | Dependencias tecnicas e componentes |
| ADRs | `output/architecture/adrs/` | Decisoes que impactam sequencia de implementacao |
| Project Brief | `output/requirements/project-brief.md` | Timeline e constraints |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Sprint Backlog | `output/planning/sprint-backlog.md` | Backlog completo com 6 sprints detalhados |

### Estrutura do sprint-backlog.md

```
# TokenOps Platform — Sprint Backlog (MVP)
## Timeline Overview (6 sprints, 3 meses)
## Sprint 1: Foundation
### Sprint Goal
### Stories alocadas (ID, titulo, story points, responsavel)
### Technical tasks
### Definition of Done
## Sprint 2: AI Gateway Core
...
## Sprint 6: Polish + Deploy
...
## Capacity Planning
## Riscos e Mitigacoes
## Dependencias Externas
```

## Execution Mode

- **Tipo**: Agent (tech-lead)
- **Requer input do usuario**: Nao — agente trabalha autonomamente
- **Automatizavel**: Sim
- **Tempo estimado**: 10-20 minutos de execucao do agente

## Quality Gate

- [ ] Todas as stories MVP alocadas em algum sprint
- [ ] Sprint goals claros e alcancaveis
- [ ] Dependencias entre sprints mapeadas
- [ ] Story points distribuidos de forma equilibrada
- [ ] Sprint 1 focado em fundacao (nao em features)
- [ ] Buffer de contingencia incluido (15-20%)
- [ ] Riscos identificados com mitigacoes
- [ ] Timeline de 3 meses respeitada
