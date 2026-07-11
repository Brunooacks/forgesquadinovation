---
step: "02"
name: "Elicitacao de Requisitos — 6 Modulos + Plugins + Plataforma"
type: agent
agent: business-analyst
tasks:
  - elicit-requirements
  - write-user-stories
depends_on: step-01
phase: requirements
---

# Step 02: Elicitacao de Requisitos — 6 Modulos + Plugins + Plataforma

## Para o Pipeline Runner

O agente Business Analyst deve ler o project brief gerado no Step 01 e produzir user stories completas para todos os 9 epicos do TokenOps Platform. As stories devem seguir o formato INVEST e incluir criterios de aceitacao no formato Given/When/Then.

### Epicos a cobrir:

1. **EP-01: AI Gateway (MVP)** — Proxy inteligente que intercepta chamadas a LLMs, conta tokens, calcula custos, aplica regras de roteamento e caching. Suporte a 7 providers.

2. **EP-02: Token Estimator (MVP)** — Motor de estimativa pre-execucao. Dado um prompt e modelo, estima tokens de input/output e custo antes de enviar ao LLM.

3. **EP-03: Model Recommendation Engine (MVP)** — Dado um tipo de task (summarization, code generation, classification, etc.), recomenda o melhor modelo considerando complexidade, contexto, criticidade, latencia e custo.

4. **EP-04: Prompt Optimization Engine (V2)** — Analisa prompts e sugere otimizacoes para reduzir tokens sem perder qualidade. Tecnicas: compression, few-shot reduction, system prompt optimization.

5. **EP-05: Remediation Engine (V2)** — Detecta anomalias de custo (spikes, drift) e executa acoes corretivas automaticas: alertas, throttling, model downgrade, budget caps.

6. **EP-06: Dashboard de Governanca (MVP)** — Visibilidade completa: total tokens, custo por modelo, custo por projeto/equipe, top prompts caros, economia potencial, tendencias.

7. **EP-07: Platform (MVP + ongoing)** — Autenticacao (JWT + OAuth), multi-tenancy (org/team/project), billing integration (Stripe), API key management, RBAC, audit log.

8. **EP-08: Chrome Extension (V2)** — Estimativa de custo inline em playgrounds (OpenAI, Anthropic Console, Google AI Studio). Badge com custo estimado antes de enviar prompt.

9. **EP-09: VS Code Extension (V2)** — Estimativa e recomendacao de modelo direto no editor. Integracao com Copilot Chat, inline cost hints.

### Personas:

- **AI Engineer**: Usa LLMs diariamente, precisa de estimativas rapidas e proxy transparente
- **Engineering Manager**: Quer visibilidade de custos por equipe/projeto, alertas de budget
- **FinOps Analyst**: Precisa de dashboards detalhados, reports, tendencias, otimizacao de custos
- **Platform Admin**: Gerencia orgs, API keys, permissoes, billing, compliance
- **Developer**: Usa extensions no editor e browser, quer feedback de custo inline

### Regras de priorizacao (MoSCoW):

- **Must Have**: Stories dos epicos MVP (EP-01, EP-02, EP-03, EP-06, EP-07 core)
- **Should Have**: Features avancadas dos epicos MVP (analytics detalhado, filtros avancados)
- **Could Have**: Epicos V2 (EP-04, EP-05, EP-08, EP-09)
- **Won't Have (this release)**: White-label, marketplace de plugins, AI fine-tuning

### Formato das User Stories:

```
### US-EPXX-NNN: [Titulo]
**Como** [persona], **quero** [acao], **para** [beneficio].

**Prioridade**: Must/Should/Could/Won't
**Story Points**: X
**Epic**: EP-XX

**Criterios de Aceitacao**:
- **Given** [contexto], **When** [acao], **Then** [resultado esperado]
- **Given** [contexto], **When** [acao], **Then** [resultado esperado]

**Dependencias**: [lista de stories ou componentes]
**Notas tecnicas**: [consideracoes de implementacao]
```

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Project Brief | `output/requirements/project-brief.md` | Briefing completo do projeto TokenOps |
| company.md | `_forgesquad/_memory/company.md` | Contexto da empresa |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | Todas as user stories organizadas por epico |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios de aceitacao detalhados (Given/When/Then) |

### Estrutura do user-stories.md

```
# TokenOps Platform — User Stories
## Resumo por Epico
| Epico | Stories | Must | Should | Could | Story Points |
## EP-01: AI Gateway
### US-EP01-001: ...
### US-EP01-002: ...
## EP-02: Token Estimator
...
## Mapa de Dependencias entre Stories
## Glossario de Termos
```

### Estrutura do acceptance-criteria.md

```
# TokenOps Platform — Acceptance Criteria
## EP-01: AI Gateway
### US-EP01-001: [Titulo]
- Given ... When ... Then ...
## EP-02: Token Estimator
...
```

## Execution Mode

- **Tipo**: Agent (business-analyst)
- **Requer input do usuario**: Nao — agente trabalha autonomamente a partir do project brief
- **Automatizavel**: Sim
- **Tempo estimado**: 15-25 minutos de execucao do agente

## Quality Gate

- [ ] Todos os 9 epicos possuem user stories
- [ ] Stories MVP (EP-01, EP-02, EP-03, EP-06, EP-07) tem cobertura completa
- [ ] Todas as 5 personas representadas nas stories
- [ ] Priorizacao MoSCoW aplicada a todas as stories
- [ ] Criterios de aceitacao em formato Given/When/Then
- [ ] Stories seguem principio INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- [ ] Mapa de dependencias entre stories documentado
- [ ] Story points estimados para todas as stories MVP
