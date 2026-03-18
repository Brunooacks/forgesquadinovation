---
step: "14"
name: "Code Review"
type: code_review
agent: tech-lead
tasks:
  - review-code
depends_on: step-13
on_reject: step-09
max_review_cycles: 3
phase: review
---

# Step 14: Tech Lead — Code Review

## Para o Pipeline Runner

Acione o agente `tech-lead` com a task `review-code`. O Tech Lead conduz uma
revisao de codigo completa cobrindo qualidade, padroes, seguranca e
manutenibilidade. Se o codigo for rejeitado, retorne ao Step 09.

### Comportamento de Rejeicao:

- **on_reject:** Retorna ao `step-09` para correcoes.
- **max_review_cycles:** 3 ciclos de revisao. Se apos 3 ciclos ainda houver
  problemas criticos, escale para o usuario via checkpoint.
- Cada ciclo de revisao deve ter feedback especifico e acionavel.

### Instrucoes para o Agente:

1. **Revise** todo o codigo implementado (backend + frontend).
2. **Avalie** cada dimensao de qualidade:

   **a) Corretude:**
   - Logica de negocio esta correta?
   - Edge cases tratados?
   - Concorrencia tratada adequadamente?

   **b) Padroes de Codigo:**
   - Nomenclatura consistente?
   - Estrutura de diretorio correta?
   - Padroes de design aplicados corretamente?
   - Codigo DRY (sem duplicacao)?

   **c) Seguranca:**
   - Validacao de input em todas as entradas?
   - SQL injection, XSS, CSRF prevenidos?
   - Autenticacao e autorizacao corretas?
   - Dados sensiveis protegidos?
   - Dependencias sem vulnerabilidades conhecidas?

   **d) Performance:**
   - Queries otimizadas (N+1, indices)?
   - Memory leaks potenciais?
   - Uso adequado de cache?

   **e) Manutenibilidade:**
   - Codigo legivel e auto-documentado?
   - Complexidade ciclomatica aceitavel?
   - Testes adequados e manuteníveis?

   **f) Observabilidade:**
   - Logging suficiente para troubleshooting?
   - Metricas relevantes expostas?

3. **Classifique** cada finding:
   - **Blocker:** Deve ser corrigido antes de prosseguir.
   - **Major:** Deve ser corrigido, mas pode ser em paralelo.
   - **Minor:** Sugestao de melhoria, nao bloqueia.
   - **Info:** Observacao educativa.

4. **Emita** um veredito: APROVADO, APROVADO COM RESSALVAS, ou REJEITADO.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Backend Code | `output/implementation/backend/` | Codigo backend |
| Frontend Code | `output/implementation/frontend/` | Codigo frontend |
| Architecture Design | `output/architecture/architecture-design.md` | Padroes a seguir |
| ADRs | `output/architecture/adrs/` | Decisoes arquiteturais |
| Test Report | `output/quality/test-report.md` | Resultados de testes |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Code Review Report | `output/review/code-review-report.md` | Relatorio detalhado do review |

### Estrutura do code-review-report.md:

```markdown
# Code Review Report — [Nome do Projeto]

## Veredito: [APROVADO / APROVADO COM RESSALVAS / REJEITADO]
- **Ciclo de revisao:** [N de max_review_cycles]
- **Data:** [data]
- **Revisor:** tech-lead

## Resumo
- **Blockers:** [N]
- **Majors:** [N]
- **Minors:** [N]
- **Info:** [N]

## Findings

### Blockers
| ID | Arquivo | Linha | Descricao | Sugestao |
|----|---------|-------|-----------|----------|
| CR-001 | [path] | [L] | [problema] | [solucao] |

### Majors
...

### Minors
...

## Metricas de Qualidade
| Metrica | Valor | Status |
|---------|-------|--------|
| Complexidade ciclomatica max | [N] | OK/NOK |
| Duplicacao de codigo | [X%] | OK/NOK |
| Cobertura de testes | [X%] | OK/NOK |

## Observacoes Gerais
[Comentarios do revisor]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `tech-lead`
- **Skills:** `review-code`
- **Timeout:** 30 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 15, verifique:

- [ ] Todos os arquivos de codigo revisados
- [ ] Zero blockers pendentes
- [ ] Majors corrigidos ou aceitos com justificativa
- [ ] Veredito emitido: APROVADO ou APROVADO COM RESSALVAS
- [ ] Relatorio de review gerado
- [ ] Numero de ciclos dentro do limite (max 3)
