---
step: "08"
name: "Aprovacao do Plano de Sprint"
type: checkpoint
depends_on: step-07
phase: planning
---

# Step 08: Checkpoint — Aprovacao do Plano de Sprint TokenOps

## Para o Pipeline Runner

Apresente ao usuario o plano de sprint MVP e a estrategia de testes para aprovacao.
Este checkpoint garante que o usuario concorda com o escopo, estimativas e
abordagem antes do inicio da implementacao do TokenOps.

### Comportamento do Checkpoint:

1. **Apresente um resumo do sprint MVP:**
   - Total de story points planejados.
   - Distribuicao por modulo (Gateway, Estimation, Recommendation, Dashboard, Platform).
   - Distribuicao por agente (backend, frontend, QA).
   - Caminho critico: Platform -> Gateway -> Dashboard API -> Dashboard UI.
   - Riscos identificados (latencia proxy, precisao estimativa, integracao providers).
2. **Apresente a estrategia de testes:**
   - Niveis de teste definidos (unitario, integracao, E2E, performance, precisao).
   - Metas de cobertura e precisao.
   - Ferramentas selecionadas.
   - Testes especificos para Token Estimation accuracy e Gateway performance.
3. **Solicite** feedback:
   - "O escopo do sprint MVP esta adequado (4 modulos)?"
   - "As estimativas parecem realistas?"
   - "A estrategia de testes cobre os cenarios criticos (latencia, precisao)?"
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
| Sprint Backlog | `output/planning/sprint-backlog.md` | Plano do sprint MVP |
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

- [ ] Usuario revisou o sprint backlog MVP
- [ ] Usuario revisou a estrategia de testes
- [ ] Aprovacao explicita registrada
- [ ] Todas as duvidas respondidas
- [ ] Ajustes solicitados incorporados (se houver)
- [ ] Registro de aprovacao gerado
