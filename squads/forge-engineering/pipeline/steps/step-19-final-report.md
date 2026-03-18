---
step: "19"
name: "Relatorio Final e Handover para Sustentacao"
type: agent
agent: project-manager
tasks:
  - generate-status-report
depends_on: step-18
phase: sustaining
---

# Step 19: Project Manager — Relatorio Final e Handover

## Para o Pipeline Runner

Acione o agente `project-manager` com a task `generate-status-report`. O Project
Manager deve compilar um relatorio final abrangente do projeto e preparar o
handover para a equipe de sustentacao.

### Instrucoes para o Agente:

1. **Compile** metricas do projeto:
   - Total de user stories entregues vs. planejadas.
   - Story points entregues vs. estimados.
   - Desvio de estimativa (accuracy ratio).
   - Ciclos de revisao utilizados.
   - Bugs encontrados por fase.
   - Cobertura de testes alcancada.
2. **Analise** o processo:
   - Gargalos identificados na pipeline.
   - Tempo gasto por fase.
   - Retrabalho (ciclos de revisao, correcoes).
   - Efetividade dos checkpoints.
3. **Documente** licoes aprendidas:
   - O que funcionou bem.
   - O que pode melhorar.
   - Riscos que se materializaram e como foram tratados.
   - Recomendacoes para projetos futuros.
4. **Prepare** o handover para sustentacao:
   - Lista de todos os artefatos produzidos.
   - Mapa de componentes e responsabilidades.
   - Problemas conhecidos e workarounds.
   - Divida tecnica pendente com prioridade.
   - Contatos da equipe de desenvolvimento.
   - Procedimentos de escalamento.
5. **Compile** inventario de artefatos:
   - Todos os documentos gerados com caminhos.
   - Status de cada artefato (completo, parcial, pendente).

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Project Brief | `output/requirements/project-brief.md` | Escopo original |
| User Stories | `output/requirements/user-stories.md` | Requisitos planejados |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Planejamento original |
| Test Report | `output/quality/test-report.md` | Resultados de testes |
| Performance Report | `output/quality/performance-report.md` | Resultados de performance |
| Code Review Report | `output/review/code-review-report.md` | Review findings |
| Arch Review Report | `output/review/arch-review-report.md` | Conformidade arquitetural |
| Deploy Report | `output/deployment/deploy-report.md` | Resultado do deploy |
| Runbook | `output/documentation/runbook.md` | Guia operacional |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Final Report | `output/reports/final-report.md` | Relatorio final consolidado |

### Estrutura do final-report.md:

```markdown
# Relatorio Final — [Nome do Projeto]

## 1. Resumo Executivo
- **Status:** Concluido
- **Data de inicio:** [data]
- **Data de conclusao:** [data]
- **Duracao total:** [X dias]

## 2. Escopo Entregue
| Metrica | Planejado | Entregue | Desvio |
|---------|-----------|----------|--------|
| User Stories | [N] | [N] | [X%] |
| Story Points | [N] | [N] | [X%] |
| Endpoints API | [N] | [N] | [X%] |
| Telas/Paginas | [N] | [N] | [X%] |

## 3. Metricas de Qualidade
| Metrica | Meta | Alcancado | Status |
|---------|------|-----------|--------|
| Cobertura de testes | [X%] | [X%] | OK/NOK |
| Testes passando | 100% | [X%] | OK/NOK |
| Bugs criticos | 0 | [N] | OK/NOK |
| Code review cycles | <=3 | [N] | OK/NOK |

## 4. Timeline por Fase
| Fase | Inicio | Fim | Duracao |
|------|--------|-----|---------|
| Requisitos | [data] | [data] | [X dias] |
| Arquitetura | [data] | [data] | [X dias] |
| Planejamento | [data] | [data] | [X dias] |
| Implementacao | [data] | [data] | [X dias] |
| Qualidade | [data] | [data] | [X dias] |
| Review | [data] | [data] | [X dias] |
| Documentacao | [data] | [data] | [X dias] |
| Deploy | [data] | [data] | [X dias] |

## 5. Licoes Aprendidas
### O que funcionou bem
- [licao 1]

### O que pode melhorar
- [licao 1]

### Riscos materializados
- [risco e tratamento]

## 6. Handover para Sustentacao
### Artefatos Produzidos
[Lista completa com caminhos]

### Problemas Conhecidos
| ID | Descricao | Workaround | Prioridade |
|----|-----------|-----------|-----------|
| KI-001 | [descricao] | [workaround] | Media |

### Divida Tecnica Pendente
| ID | Descricao | Prioridade | Impacto |
|----|-----------|-----------|---------|
| TD-001 | [descricao] | Alta | [impacto] |

### Contatos e Escalonamento
| Papel | Nome/Agente | Responsabilidade |
|-------|-------------|-----------------|
| Tech Lead | tech-lead | Decisoes tecnicas |
| Architect | architect | Arquitetura |

## 7. Recomendacoes para Projetos Futuros
- [recomendacao 1]
- [recomendacao 2]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `project-manager`
- **Skills:** `generate-status-report`
- **Timeout:** 30 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 20, verifique:

- [ ] Todas as metricas do projeto compiladas
- [ ] Licoes aprendidas documentadas
- [ ] Handover para sustentacao completo
- [ ] Inventario de artefatos com caminhos
- [ ] Divida tecnica documentada
- [ ] Problemas conhecidos listados
- [ ] Relatorio final gerado
