---
step: "06"
name: "Sprint Planning"
type: agent
agent: tech-lead
tasks:
  - plan-sprint
depends_on: step-05
phase: planning
---

# Step 06: Tech Lead — Sprint Planning

## Para o Pipeline Runner

Acione o agente `tech-lead` com a task `plan-sprint`. O Tech Lead deve decompor
os requisitos aprovados em tarefas tecnicas, estimar complexidade e organizar
o backlog do sprint considerando a arquitetura definida.

### Instrucoes para o Agente:

1. **Leia** os requisitos aprovados e a arquitetura definida.
2. **Decomponha** cada user story em tarefas tecnicas:
   - Tarefas de backend (API, banco, logica de negocio).
   - Tarefas de frontend (UI, integracao, testes).
   - Tarefas de infraestrutura (CI/CD, deploy, monitoramento).
   - Tarefas de qualidade (testes, automacao).
3. **Estime** cada tarefa:
   - Story points (Fibonacci: 1, 2, 3, 5, 8, 13).
   - Complexidade (baixa, media, alta).
4. **Defina** a ordem de execucao considerando:
   - Dependencias tecnicas entre tarefas.
   - Prioridade de negocio (MoSCoW das user stories).
   - Caminho critico do projeto.
5. **Atribua** tarefas aos agentes da squad (backend, frontend, QA).
6. **Identifique** riscos e mitigacoes para o sprint.

### Regras:

- Nenhuma tarefa deve exceder 8 story points (dividir se necessario).
- Incluir buffer de 20% para imprevistos.
- Dependencias devem estar claramente mapeadas.
- Cada tarefa deve ter criterio de "done" definido.

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
| Sprint Backlog | `output/planning/sprint-backlog.md` | Backlog completo do sprint com tarefas estimadas |

### Estrutura do sprint-backlog.md:

```markdown
# Sprint Backlog — [Nome do Projeto]

## Resumo do Sprint
- **Objetivo:** [objetivo do sprint]
- **Duracao:** [X semanas]
- **Capacidade:** [total story points]
- **Velocidade estimada:** [story points por semana]

## Tarefas

### US-001: [Titulo da Story]
| ID | Tarefa | Agente | Story Points | Dependencia | Status |
|----|--------|--------|-------------|-------------|--------|
| T-001 | [Descricao] | dev-backend | 3 | - | Pendente |
| T-002 | [Descricao] | dev-frontend | 5 | T-001 | Pendente |

### US-002: [Titulo da Story]
...

## Caminho Critico
[Lista de tarefas no caminho critico]

## Riscos e Mitigacoes
| Risco | Probabilidade | Impacto | Mitigacao |
|-------|--------------|---------|-----------|
| [Risco 1] | Alta | Alto | [Mitigacao] |
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `tech-lead`
- **Skills:** `plan-sprint`
- **Timeout:** 30 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 07, verifique:

- [ ] Todas as user stories foram decompostas em tarefas
- [ ] Cada tarefa estimada em story points
- [ ] Dependencias mapeadas
- [ ] Tarefas atribuidas a agentes
- [ ] Caminho critico identificado
- [ ] Riscos documentados com mitigacoes
- [ ] Nenhuma tarefa excede 8 story points
- [ ] Buffer de 20% incluido
