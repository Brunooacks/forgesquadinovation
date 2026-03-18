---
step: "05"
name: "Revisao Arquitetural"
type: architectural_review
depends_on: step-04
phase: architecture
---

# Step 05: Checkpoint — Revisao Arquitetural

## Para o Pipeline Runner

Este e um checkpoint de revisao arquitetural. Apresente o design de arquitetura
ao usuario junto com uma analise critica dos trade-offs. O usuario deve aprovar
a arquitetura antes de prosseguir para o planejamento.

### Comportamento do Checkpoint:

1. **Apresente um resumo executivo** da arquitetura:
   - Estilo arquitetural escolhido e justificativa.
   - Componentes principais e suas responsabilidades.
   - Stack tecnologica selecionada.
   - Principais trade-offs e riscos identificados.
2. **Destaque decisoes criticas** (ADRs) que requerem atencao:
   - Liste cada ADR com titulo e resumo da decisao.
   - Indique as consequencias de cada decisao.
3. **Solicite** feedback especifico:
   - "A arquitetura atende aos requisitos do projeto?"
   - "Os trade-offs sao aceitaveis?"
   - "Alguma decisao tecnologica precisa ser reconsiderada?"
4. **Processe** a decisao:
   - **Aprovado:** Avance para o Step 06.
   - **Alteracoes solicitadas:** Retorne ao Step 04 com feedback.
   - **Rejeitado:** Retorne ao Step 03 para reavaliar requisitos.

### Regras:

- O Arquiteto deve estar preparado para defender cada decisao.
- Alternativas descartadas devem ser mencionadas com justificativa.
- Nao avance sem aprovacao explicita.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Design completo |
| ADRs | `output/architecture/adrs/` | Todas as ADRs |
| User Stories | `output/requirements/user-stories.md` | Para validacao de cobertura |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Review Record | `output/architecture/architecture-review-record.md` | Registro da revisao com decisao e observacoes |

## Execution Mode

- **Modo:** Interativo (checkpoint humano)
- **Agente:** Nenhum
- **Skills:** Nenhuma

## Quality Gate

Antes de avancar para o Step 06, verifique:

- [ ] Usuario revisou o documento de arquitetura
- [ ] ADRs foram apresentadas e discutidas
- [ ] Trade-offs foram aceitos explicitamente
- [ ] Aprovacao registrada com timestamp
- [ ] Nenhuma questao critica pendente
