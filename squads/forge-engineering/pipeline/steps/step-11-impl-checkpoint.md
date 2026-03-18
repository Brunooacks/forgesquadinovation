---
step: "11"
name: "Checkpoint de Implementacao"
type: checkpoint
depends_on: step-10
phase: implementation
---

# Step 11: Checkpoint — Revisao de Implementacao

## Para o Pipeline Runner

Apresente ao usuario o progresso da implementacao (backend e frontend) para
revisao intermediaria. Este checkpoint permite ajustes antes de prosseguir
para a fase de qualidade.

### Comportamento do Checkpoint:

1. **Apresente o status da implementacao:**
   - Tarefas concluidas vs. planejadas.
   - Story points entregues vs. planejados.
   - Testes unitarios: quantidade e cobertura.
   - Testes de componente: quantidade e cobertura.
   - Issues encontrados durante implementacao.
2. **Demonstre** funcionalidades implementadas:
   - Lista de endpoints de API disponiveis.
   - Paginas e fluxos implementados.
   - Integracoes funcionais.
3. **Solicite** feedback:
   - "A implementacao esta alinhada com as expectativas?"
   - "Alguma funcionalidade precisa de ajuste?"
   - "O comportamento dos fluxos esta correto?"
4. **Processe** a decisao:
   - **Aprovado:** Avance para o Step 12 (qualidade).
   - **Ajustes solicitados:** Retorne ao Step 09 ou Step 10 com feedback especifico.
   - **Escopo alterado:** Retorne ao Step 06 para replanejamento.

### Regras:

- Nao avance para testes automatizados com bugs conhecidos criticos.
- Se mais de 30% das tarefas estiverem pendentes, considere replanejamento.
- Feedback do usuario deve ser registrado para rastreabilidade.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Backend Code | `output/implementation/backend/` | Codigo backend |
| Frontend Code | `output/implementation/frontend/` | Codigo frontend |
| Backend Report | `output/implementation/backend/implementation-report.md` | Relatorio backend |
| Frontend Report | `output/implementation/frontend/implementation-report.md` | Relatorio frontend |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Referencia de tarefas planejadas |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Implementation Review | `output/implementation/impl-review-record.md` | Registro da revisao com decisao |

## Execution Mode

- **Modo:** Interativo (checkpoint humano)
- **Agente:** Nenhum
- **Skills:** Nenhuma

## Quality Gate

Antes de avancar para o Step 12, verifique:

- [ ] Usuario revisou o progresso da implementacao
- [ ] Nenhum bug critico pendente
- [ ] Testes unitarios e de componente passando
- [ ] Aprovacao explicita registrada
- [ ] Ajustes solicitados incorporados (se houver)
- [ ] Registro de revisao gerado
