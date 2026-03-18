---
step: "20"
name: "Encerramento"
type: checkpoint
depends_on: step-19
phase: sustaining
---

# Step 20: Checkpoint — Encerramento do Projeto

## Para o Pipeline Runner

Este e o ultimo passo da pipeline. Apresente ao usuario o relatorio final,
confirme o encerramento formal do projeto e registre a transicao para sustentacao.

### Comportamento do Checkpoint:

1. **Apresente o relatorio final:**
   - Resumo executivo do projeto.
   - Metricas de entrega vs. planejamento.
   - Metricas de qualidade alcancadas.
   - Status do deploy em producao.
2. **Apresente o handover para sustentacao:**
   - Artefatos disponíveis para a equipe de sustentacao.
   - Problemas conhecidos e workarounds.
   - Divida tecnica pendente.
   - Procedimentos operacionais (runbook).
3. **Apresente licoes aprendidas:**
   - O que funcionou bem na pipeline.
   - Oportunidades de melhoria para proximos projetos.
4. **Solicite** confirmacao de encerramento:
   - "O projeto esta formalmente encerrado?"
   - "A equipe de sustentacao recebeu todas as informacoes necessarias?"
   - "Alguma pendencia precisa ser registrada?"
5. **Processe** a decisao:
   - **Encerrado:** Registre o encerramento formal.
   - **Pendencias:** Liste pendencias e responsaveis.

### Regras:

- Nao encerre com pendencias criticas nao documentadas.
- Garantir que a equipe de sustentacao tem acesso a todos os artefatos.
- Registrar formalmente a data e hora do encerramento.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Final Report | `output/reports/final-report.md` | Relatorio final consolidado |
| Deploy Report | `output/deployment/deploy-report.md` | Status do deploy |
| Runbook | `output/documentation/runbook.md` | Guia operacional |
| API Docs | `output/documentation/api-docs.md` | Documentacao de API |
| Release Notes | `output/documentation/release-notes.md` | Notas de release |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Closure Record | `output/reports/closure-record.md` | Registro formal de encerramento |

### Estrutura do closure-record.md:

```markdown
# Registro de Encerramento — [Nome do Projeto]

## Dados do Encerramento
- **Data:** [data]
- **Hora:** [hora]
- **Aprovado por:** [usuario]

## Status Final
- **Projeto:** Concluido
- **Deploy:** Em producao
- **Sustentacao:** Transferida para [equipe]

## Checklist de Encerramento
- [x] Codigo entregue e versionado
- [x] Testes automatizados implementados e passando
- [x] Documentacao tecnica completa
- [x] Runbook operacional disponivel
- [x] Monitoramento e alertas configurados
- [x] Equipe de sustentacao informada
- [x] Divida tecnica documentada
- [x] Licoes aprendidas registradas
- [x] Relatorio final aprovado

## Pendencias Pos-Encerramento (se houver)
| ID | Descricao | Responsavel | Prazo |
|----|-----------|------------|-------|
| PD-001 | [descricao] | [responsavel] | [data] |

## Artefatos Entregues
| Artefato | Caminho | Status |
|----------|---------|--------|
| Project Brief | output/requirements/project-brief.md | Completo |
| User Stories | output/requirements/user-stories.md | Completo |
| Acceptance Criteria | output/requirements/acceptance-criteria.md | Completo |
| Architecture Design | output/architecture/architecture-design.md | Completo |
| ADRs | output/architecture/adrs/ | Completo |
| Sprint Backlog | output/planning/sprint-backlog.md | Completo |
| Test Strategy | output/planning/test-strategy.md | Completo |
| Backend Code | output/implementation/backend/ | Completo |
| Frontend Code | output/implementation/frontend/ | Completo |
| Test Report | output/quality/test-report.md | Completo |
| Performance Report | output/quality/performance-report.md | Completo/N.A. |
| Code Review Report | output/review/code-review-report.md | Completo |
| Arch Review Report | output/review/arch-review-report.md | Completo |
| API Docs | output/documentation/api-docs.md | Completo |
| Runbook | output/documentation/runbook.md | Completo |
| Release Notes | output/documentation/release-notes.md | Completo |
| Deploy Report | output/deployment/deploy-report.md | Completo |
| Final Report | output/reports/final-report.md | Completo |

## Assinatura
Pipeline ForgeSquad v1.0.0 — Projeto encerrado com sucesso.
```

## Execution Mode

- **Modo:** Interativo (checkpoint humano)
- **Agente:** Nenhum
- **Skills:** Nenhuma

## Quality Gate

Criterios finais para encerramento:

- [ ] Relatorio final revisado e aprovado pelo usuario
- [ ] Handover para sustentacao confirmado
- [ ] Todas as pendencias documentadas (se houver)
- [ ] Registro de encerramento gerado
- [ ] Aprovacao formal do usuario registrada
- [ ] Pipeline concluida com sucesso
