---
step: "06"
name: "Sprint Planning — MVP TokenOps"
type: agent
agent: tech-lead
tasks:
  - plan-sprint
depends_on: step-05
phase: planning
---

# Step 06: Tech Lead — Sprint Planning MVP TokenOps

## Para o Pipeline Runner

Acione o agente `tech-lead` com a task `plan-sprint`. O Tech Lead deve decompor
os requisitos MVP do TokenOps em tarefas tecnicas, estimar complexidade e organizar
o backlog do sprint considerando a arquitetura definida com foco nos 4 modulos MVP.

### Instrucoes para o Agente:

1. **Leia** os requisitos aprovados e a arquitetura definida.
2. **Decomponha** cada user story MVP em tarefas tecnicas agrupadas por modulo:

   **AI Gateway:**
   - Setup do proxy reverso NestJS
   - Implementacao do LLM provider adapter (OpenAI, Anthropic, Google, Bedrock, Azure)
   - Rate limiting por tenant/API key (Redis)
   - Circuit breaker por provider
   - Request/response logging para analytics pipeline
   - Testes de integracao com providers

   **Token Estimation Engine:**
   - Integracao de tokenizers por modelo (tiktoken, etc.)
   - API de estimativa pre-envio
   - Cache de estimativas (Redis)
   - Calculo de custo estimado
   - Testes de precisao do estimator

   **Model Recommendation Engine:**
   - Pricing tables por provider/modelo
   - Algoritmo de ranking custo/qualidade
   - API de recomendacao
   - Testes de qualidade das recomendacoes

   **Dashboard:**
   - Next.js setup com Tailwind CSS
   - Pagina de overview (metricas agregadas)
   - Graficos de uso de tokens por periodo
   - Graficos de custo por modelo/provider
   - Filtros por time/projeto/modelo/periodo
   - Integracao com Dashboard API

   **Platform (cross-cutting):**
   - Multi-tenancy setup (PostgreSQL row-level)
   - Autenticacao e API key management
   - Configuracao ClickHouse para analytics
   - Setup de observabilidade (OpenTelemetry)

3. **Estime** cada tarefa em story points (Fibonacci: 1, 2, 3, 5, 8, 13).
4. **Defina** a ordem de execucao considerando:
   - Platform setup primeiro (infraestrutura base)
   - Gateway segundo (core do produto)
   - Token Estimation e Model Recommendation em paralelo
   - Dashboard por ultimo (depende das APIs)
5. **Atribua** tarefas aos agentes da squad.
6. **Identifique** riscos e mitigacoes para o sprint.

### Regras:

- Nenhuma tarefa deve exceder 8 story points (dividir se necessario).
- Incluir buffer de 20% para imprevistos.
- Dependencias devem estar claramente mapeadas.
- Cada tarefa deve ter criterio de "done" definido.
- Priorizar Gateway como caminho critico do MVP.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | Requisitos priorizados |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios de aceitacao |
| Architecture Design | `output/architecture/architecture-design.md` | Arquitetura aprovada |
| ADRs | `output/architecture/adrs/` | Decisoes arquiteturais |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Sprint Backlog | `output/planning/sprint-backlog.md` | Backlog completo do sprint MVP com tarefas estimadas |

### Estrutura do sprint-backlog.md:

```markdown
# Sprint Backlog — TokenOps MVP

## Resumo do Sprint
- **Objetivo:** Entregar MVP com Gateway + Dashboard + Token Estimation + Model Recommendation
- **Duracao:** [X semanas]
- **Capacidade:** [total story points]
- **Velocidade estimada:** [story points por semana]

## Tarefas por Modulo

### Platform (Cross-cutting)
| ID | Tarefa | Agente | SP | Dep | Status |
|----|--------|--------|-----|-----|--------|
| T-001 | Multi-tenancy setup | dev-backend | 5 | - | Pendente |

### AI Gateway
| ID | Tarefa | Agente | SP | Dep | Status |
|----|--------|--------|-----|-----|--------|
| T-010 | Proxy reverso NestJS | dev-backend | 8 | T-001 | Pendente |

### Token Estimation Engine
...

### Model Recommendation Engine
...

### Dashboard
...

## Caminho Critico
Platform -> Gateway -> Dashboard API -> Dashboard UI

## Riscos e Mitigacoes
| Risco | Probabilidade | Impacto | Mitigacao |
|-------|--------------|---------|-----------|
| Latencia do proxy acima do target | Media | Alto | Benchmark cedo, otimizar hot path |
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `tech-lead`
- **Skills:** `plan-sprint`
- **Timeout:** 30 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 07, verifique:

- [ ] Todas as user stories MVP decompostas em tarefas
- [ ] Cada tarefa estimada em story points
- [ ] Dependencias mapeadas entre modulos
- [ ] Tarefas atribuidas a agentes
- [ ] Caminho critico identificado (Platform -> Gateway -> Dashboard)
- [ ] Riscos documentados com mitigacoes
- [ ] Nenhuma tarefa excede 8 story points
- [ ] Buffer de 20% incluido
