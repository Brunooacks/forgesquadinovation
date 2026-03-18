---
step: "03"
name: "Aprovacao dos Requisitos"
type: checkpoint
depends_on: step-02
phase: requirements
---

# Step 03: Checkpoint — Aprovacao dos Requisitos

## Para o Pipeline Runner

Apresente ao usuario os artefatos de requisitos gerados pelo Business Analyst para
revisao e aprovacao. O usuario pode aprovar, solicitar alteracoes ou rejeitar.

### Comportamento do Checkpoint:

1. **Apresente um resumo** dos requisitos:
   - Numero total de epicos e user stories.
   - Distribuicao por prioridade (Must/Should/Could/Won't).
   - Lista de requisitos nao-funcionais identificados.
2. **Disponibilize** os artefatos completos para leitura.
3. **Solicite** feedback especifico:
   - "Os requisitos cobrem todos os cenarios do seu projeto?"
   - "Alguma user story esta incorreta ou faltando?"
   - "As prioridades estao adequadas?"
4. **Processe** a decisao:
   - **Aprovado:** Avance para o Step 04.
   - **Alteracoes solicitadas:** Retorne ao Step 02 com feedback especifico.
   - **Rejeitado:** Retorne ao Step 01 para revisao do briefing.

### Regras:

- Nao avance sem aprovacao explicita do usuario.
- Registre todas as alteracoes solicitadas para rastreabilidade.
- Maximo de 3 ciclos de revisao antes de escalar.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | User stories geradas |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios de aceitacao |
| Project Brief | `output/requirements/project-brief.md` | Briefing original para referencia |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Approval Record | `output/requirements/approval-record.md` | Registro da aprovacao com data e observacoes |

## Execution Mode

- **Modo:** Interativo (checkpoint humano)
- **Agente:** Nenhum
- **Skills:** Nenhuma

## Quality Gate

Antes de avancar para o Step 04, verifique:

- [ ] Usuario revisou os artefatos de requisitos
- [ ] Aprovacao explicita registrada
- [ ] Todas as alteracoes solicitadas foram incorporadas
- [ ] Arquivo de aprovacao gerado com timestamp
- [ ] Nao ha pendencias ou duvidas abertas
