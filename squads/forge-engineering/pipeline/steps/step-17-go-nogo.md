---
step: "17"
name: "Go/No-Go para Producao"
type: checkpoint
depends_on: step-16
phase: deployment
---

# Step 17: Checkpoint — Go/No-Go para Producao

## Para o Pipeline Runner

Este e o checkpoint mais critico da pipeline. Apresente ao usuario um dashboard
consolidado com todas as metricas de qualidade, resultados de testes, status de
reviews e documentacao para decisao de Go/No-Go para deploy em producao.

### Comportamento do Checkpoint:

1. **Compile** e apresente o dashboard de qualidade:

   **a) Status de Testes:**
   - Testes unitarios: [N passaram / N total]
   - Testes de integracao: [N passaram / N total]
   - Testes E2E: [N passaram / N total]
   - Testes de performance: [status] (se aplicavel)
   - Cobertura de codigo: [X%]

   **b) Status de Reviews:**
   - Code Review: [APROVADO / COM RESSALVAS / REJEITADO]
   - Revisao Arquitetural: [CONFORME / PARCIALMENTE CONFORME]
   - Ciclos de revisao: [N de max]

   **c) Qualidade do Codigo:**
   - Blockers resolvidos: [N/N]
   - Majors resolvidos: [N/N]
   - Divida tecnica identificada: [N itens]

   **d) Documentacao:**
   - API Docs: [Completo/Parcial]
   - Runbook: [Completo/Parcial]
   - Release Notes: [Completo/Parcial]

   **e) Riscos Remanescentes:**
   - [Lista de riscos abertos]

2. **Emita** recomendacao:
   - **GO:** Todas as metricas dentro dos limites, sem blockers.
   - **GO com condicoes:** Metricas aceitaveis, mas com ressalvas documentadas.
   - **NO-GO:** Blockers abertos ou metricas fora do limite.

3. **Solicite** decisao do usuario:
   - "Com base nos dados acima, aprova o deploy em producao?"
   - Se NO-GO, indique os passos necessarios para resolver.

4. **Processe** a decisao:
   - **GO:** Avance para o Step 18.
   - **NO-GO:** Retorne ao step adequado para correcoes.

### Regras:

- Nao avance sem aprovacao explicita do usuario.
- Mesmo com recomendacao GO, o usuario pode decidir NO-GO.
- Toda decisao deve ser documentada com justificativa.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Report | `output/quality/test-report.md` | Resultados de testes |
| Performance Report | `output/quality/performance-report.md` | Resultados de performance (se houver) |
| Code Review Report | `output/review/code-review-report.md` | Resultado do code review |
| Arch Review Report | `output/review/arch-review-report.md` | Resultado da revisao arquitetural |
| API Docs | `output/documentation/api-docs.md` | Documentacao de API |
| Runbook | `output/documentation/runbook.md` | Runbook operacional |
| Release Notes | `output/documentation/release-notes.md` | Notas de release |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Go/No-Go Record | `output/deployment/go-nogo-record.md` | Registro da decisao com evidencias |

## Execution Mode

- **Modo:** Interativo (checkpoint humano)
- **Agente:** Nenhum
- **Skills:** Nenhuma

## Quality Gate

Antes de avancar para o Step 18, verifique:

- [ ] Dashboard de qualidade compilado e apresentado
- [ ] Todas as metricas revisadas pelo usuario
- [ ] Decisao GO explicita registrada
- [ ] Riscos remanescentes aceitos com ciencia
- [ ] Registro de Go/No-Go gerado com timestamp
- [ ] Runbook disponivel para uso no deploy
