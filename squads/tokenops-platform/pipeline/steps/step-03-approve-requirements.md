---
step: "03"
name: "Aprovacao dos Requisitos"
type: checkpoint
depends_on: step-02
phase: requirements
---

# Step 03: Aprovacao dos Requisitos

## Para o Pipeline Runner

Este checkpoint apresenta ao usuario um resumo consolidado dos requisitos elicitados no Step 02 para revisao e aprovacao. O Pipeline Runner deve exibir as metricas chave e aguardar aprovacao explicita antes de prosseguir para o design de arquitetura.

### Informacoes a apresentar:

1. **Resumo por Epico**:
   - Numero total de user stories por epico
   - Distribuicao MoSCoW (Must/Should/Could/Won't)
   - Story points totais por epico
   - Cobertura de personas por epico

2. **Escopo MVP vs V2/V3**:
   - Lista de epicos MVP: EP-01 (AI Gateway), EP-02 (Token Estimator), EP-03 (Model Recommendation), EP-06 (Dashboard), EP-07 (Platform core)
   - Lista de epicos V2: EP-04 (Prompt Optimization), EP-05 (Remediation), EP-08 (Chrome Extension), EP-09 (VS Code Extension)
   - Total de story points MVP vs total geral

3. **Dependencias criticas**:
   - Stories bloqueadoras (EP-07 Platform como fundacao)
   - Cadeia critica para MVP delivery
   - Riscos de dependencias externas (LLM provider APIs)

4. **Gaps e riscos identificados**:
   - Stories que podem ter escopo ambiguo
   - Areas sem cobertura de acceptance criteria
   - Riscos de complexidade subestimada

### Perguntas ao usuario:

- Os epicos MVP estao corretos e completos?
- Alguma story deve ser reprioritizada?
- Algum requisito esta faltando?
- Os criterios de aceitacao sao verificaveis?
- O escopo MVP e viavel em 3 meses?

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| User Stories | `output/requirements/user-stories.md` | User stories completas por epico |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios de aceitacao detalhados |
| Project Brief | `output/requirements/project-brief.md` | Briefing original para referencia |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Aprovacao registrada | (inline no pipeline state) | Registro de aprovacao ou solicitacao de ajustes |

### Em caso de ajustes solicitados:

O Pipeline Runner deve retornar ao Step 02 com as instrucoes de ajuste do usuario, e o agente BA deve reprocessar apenas as stories afetadas.

## Execution Mode

- **Tipo**: Checkpoint (interativo)
- **Requer input do usuario**: Sim — revisao e aprovacao explicita
- **Automatizavel**: Nao — depende de julgamento humano
- **Tempo estimado**: 15-30 minutos de revisao

## Quality Gate

- [ ] Todas as stories MVP revisadas pelo usuario
- [ ] Criterios de aceitacao considerados verificaveis
- [ ] Todas as 5 personas mapeadas em pelo menos uma story
- [ ] Dependencias entre stories validadas
- [ ] Escopo MVP confirmado como viavel para timeline de 3 meses
- [ ] Nenhuma story critica sem acceptance criteria
- [ ] Aprovacao explicita do usuario registrada
