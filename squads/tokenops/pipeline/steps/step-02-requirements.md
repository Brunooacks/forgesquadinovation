---
step: "02"
name: "Elicitacao de Requisitos — Modulos TokenOps"
type: agent
agent: business-analyst
tasks:
  - elicit-requirements
  - write-user-stories
depends_on: step-01
phase: requirements
---

# Step 02: Business Analyst — Elicitacao de Requisitos TokenOps

## Para o Pipeline Runner

Acione o agente `business-analyst` com as tasks `elicit-requirements` e `write-user-stories`.
O agente deve analisar o project brief do TokenOps e produzir user stories completas
para os 6 modulos, priorizando os 4 modulos do MVP.

### Instrucoes para o Agente:

1. **Leia** o arquivo `output/requirements/project-brief.md` completamente.
2. **Identifique** os epicos principais — um por modulo TokenOps:
   - **EP-01: AI Gateway** — Proxy inteligente para chamadas LLM (MVP)
   - **EP-02: Dashboard** — Painel de metricas e controle de uso (MVP)
   - **EP-03: Token Estimation** — Motor de estimativa de tokens pre-envio (MVP)
   - **EP-04: Model Recommendation** — Recomendacao de modelo otimo custo/qualidade (MVP)
   - **EP-05: Cost Explorer** — Explorador de custos detalhado (pos-MVP)
   - **EP-06: Alerts & Budgets** — Sistema de alertas e orcamentos (pos-MVP)
   - **EP-07: Platform** — Autenticacao, multi-tenancy, billing, API keys
3. **Decomponha** cada epico em user stories no formato:
   - "Como [persona], eu quero [acao] para que [beneficio]."
4. **Personas principais:**
   - **Engenheiro de AI** — Integra LLMs via Gateway, monitora tokens
   - **Engineering Manager** — Acompanha custos, define budgets
   - **FinOps Analyst** — Analisa custos, otimiza gastos, gera relatorios
   - **Platform Admin** — Gerencia times, API keys, configuracoes
5. **Escreva** criterios de aceitacao para cada user story no formato Given/When/Then.
6. **Priorize** usando MoSCoW — modulos MVP sao Must Have.
7. **Identifique** dependencias entre stories e entre modulos.
8. **Mapeie** requisitos nao-funcionais como cross-cutting concerns:
   - Latencia do proxy (< Xms overhead)
   - Precisao da estimativa de tokens (> X%)
   - Qualidade da recomendacao de modelo
   - Multi-tenancy e isolamento de dados

### Regras:

- Cada user story deve ser independente, negociavel, valiosa, estimavel, pequena e testavel (INVEST).
- Criterios de aceitacao devem ser verificaveis e automatizaveis.
- Inclua user stories para fluxos de erro e edge cases (ex: LLM provider down, token limit exceeded).
- Stories de modulos pos-MVP devem ser escritas mas marcadas como Won't (this sprint).
- Considere cenarios de rate limiting, circuit breaker e fallback no Gateway.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Project Brief | `output/requirements/project-brief.md` | Briefing completo do TokenOps |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | Lista completa de user stories por modulo, priorizadas |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios de aceitacao detalhados por story |

### Estrutura do user-stories.md:

```markdown
# User Stories — TokenOps

## EP-01: AI Gateway (MVP)
### US-001: Proxy de chamadas LLM
- **Como** engenheiro de AI
- **Quero** enviar chamadas LLM atraves do Gateway TokenOps
- **Para que** todas as chamadas sejam rastreadas e otimizadas automaticamente
- **Prioridade:** Must Have
- **Estimativa:** [story points]
- **Dependencias:** [lista]

### US-002: Routing inteligente entre modelos
...

## EP-02: Dashboard (MVP)
### US-010: Visao geral de consumo
...

## EP-03: Token Estimation (MVP)
### US-020: Estimativa de tokens antes do envio
...

## EP-04: Model Recommendation (MVP)
### US-030: Sugestao de modelo otimo
...

## EP-05: Cost Explorer (Pos-MVP)
...

## EP-06: Alerts & Budgets (Pos-MVP)
...

## EP-07: Platform
### US-060: Multi-tenancy e isolamento
...
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `business-analyst`
- **Skills:** `elicit-requirements`, `write-user-stories`
- **Timeout:** 45 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 03, verifique:

- [ ] Todas as user stories seguem o formato padrao
- [ ] Cada story tem pelo menos 2 criterios de aceitacao
- [ ] Stories estao priorizadas (MoSCoW) com MVP como Must Have
- [ ] 4 modulos MVP completamente cobertos (Gateway, Dashboard, Estimation, Recommendation)
- [ ] Requisitos nao-funcionais mapeados (latencia proxy, precisao estimativa)
- [ ] Fluxos de erro foram considerados (provider down, rate limit, token overflow)
- [ ] Dependencias entre stories e modulos identificadas
- [ ] Personas corretas atribuidas a cada story
- [ ] Arquivos gerados nos caminhos corretos
