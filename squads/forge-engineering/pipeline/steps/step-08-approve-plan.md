---
step: "08"
name: "Aprovacao do Plano de Sprint"
type: checkpoint
depends_on: step-07
phase: planning
---

# Step 08: Checkpoint — Aprovacao do Plano de Sprint

## Para o Pipeline Runner

Apresente ao usuario o plano de sprint e a estrategia de testes para aprovacao.
Este checkpoint garante que o usuario concorda com o escopo, estimativas e
abordagem antes do inicio da implementacao.

### Comportamento do Checkpoint:

1. **Apresente um resumo do sprint:**
   - Total de story points planejados.
   - Distribuicao de tarefas por agente (backend, frontend, QA).
   - Caminho critico e dependencias.
   - Riscos identificados e mitigacoes.
2. **Apresente a estrategia de testes:**
   - Niveis de teste definidos.
   - Metas de cobertura.
   - Ferramentas selecionadas.
3. **Solicite** feedback:
   - "O escopo do sprint esta adequado?"
   - "As estimativas parecem realistas?"
   - "A estrategia de testes e suficiente?"
   - "Algum risco nao foi considerado?"
4. **Processe** a decisao:
   - **Aprovado:** Avance para o Step 09 (implementacao).
   - **Ajustes solicitados:** Retorne ao Step 06 ou Step 07 conforme necessario.

### Regras:

- Nao inicie implementacao sem aprovacao explicita.
- Se o usuario questionar estimativas, o Tech Lead deve justificar.
- Alteracoes de escopo devem ser refletidas em ambos os artefatos.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Sprint Backlog | `output/planning/sprint-backlog.md` | Plano do sprint |
| Test Strategy | `output/planning/test-strategy.md` | Estrategia de testes |
| Architecture Design | `output/architecture/architecture-design.md` | Referencia arquitetural |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Plan Approval | `output/planning/plan-approval.md` | Registro de aprovacao do plano |

## Execution Mode

- **Modo:** Interativo (checkpoint humano)
- **Agente:** Nenhum
- **Skills:** Nenhuma

## Quality Gate

Antes de avancar para o Step 09, verifique:

- [ ] Usuario revisou o sprint backlog
- [ ] Usuario revisou a estrategia de testes
- [ ] Aprovacao explicita registrada
- [ ] Todas as duvidas respondidas
- [ ] Ajustes solicitados incorporados (se houver)
- [ ] Registro de aprovacao gerado
