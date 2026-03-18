---
step: "03"
name: "Aprovacao dos Requisitos"
type: checkpoint
depends_on: step-02
phase: requirements
---

# Step 03: Checkpoint — Aprovacao dos Requisitos TokenOps

## Para o Pipeline Runner

Apresente ao usuario os artefatos de requisitos gerados pelo Business Analyst para
revisao e aprovacao. O usuario pode aprovar, solicitar alteracoes ou rejeitar.

### Comportamento do Checkpoint:

1. **Apresente um resumo** dos requisitos:
   - Numero total de epicos (7: 4 MVP + 2 pos-MVP + 1 Platform).
   - Numero total de user stories por modulo.
   - Distribuicao por prioridade (Must/Should/Could/Won't).
   - Cobertura dos 4 modulos MVP (Gateway, Dashboard, Token Estimation, Model Recommendation).
   - Requisitos nao-funcionais identificados (latencia proxy, precisao estimativa, throughput).
2. **Destaque** decisoes de escopo:
   - O que esta incluido no MVP vs. pos-MVP.
   - Provedores LLM cobertos na primeira release.
   - Requisitos de multi-tenancy e isolamento.
3. **Disponibilize** os artefatos completos para leitura.
4. **Solicite** feedback especifico:
   - "Os requisitos cobrem todos os cenarios do TokenOps?"
   - "O escopo do MVP esta adequado (Gateway + Dashboard + Estimation + Recommendation)?"
   - "As prioridades estao corretas?"
   - "Algum provedor LLM faltando?"
5. **Processe** a decisao:
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
| User Stories | `output/requirements/user-stories.md` | User stories dos 6 modulos TokenOps |
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
- [ ] Escopo MVP confirmado (4 modulos)
- [ ] Aprovacao explicita registrada
- [ ] Todas as alteracoes solicitadas foram incorporadas
- [ ] Arquivo de aprovacao gerado com timestamp
- [ ] Nao ha pendencias ou duvidas abertas
