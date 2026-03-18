---
step: "12"
name: "Testes Automatizados"
type: agent
agent: qa-engineer
tasks:
  - write-test-cases
  - automate-tests
  - run-regression
depends_on: step-11
phase: quality
---

# Step 12: QA Engineer — Testes Automatizados

## Para o Pipeline Runner

Acione o agente `qa-engineer` com as tasks `write-test-cases`, `automate-tests`
e `run-regression`. O QA deve escrever e executar testes de integracao e E2E
conforme a estrategia de testes definida.

### Instrucoes para o Agente:

1. **Leia** a estrategia de testes, criterios de aceitacao e codigo implementado.
2. **Escreva** casos de teste de integracao:
   - Testes de contrato de API (request/response).
   - Testes de integracao com banco de dados.
   - Testes de integracao entre servicos.
   - Testes de autenticacao e autorizacao.
3. **Escreva** casos de teste E2E:
   - Fluxos criticos de negocio (happy path).
   - Fluxos alternativos e de erro.
   - Fluxos de borda (edge cases).
   - Cenarios de concorrencia (se aplicavel).
4. **Automatize** os testes:
   - Configure o framework de testes conforme estrategia.
   - Implemente fixtures e factories de dados.
   - Configure ambientes de teste (test containers, mocks).
   - Integre com CI/CD pipeline.
5. **Execute** a suite de regressao:
   - Rode todos os testes (unitarios + integracao + E2E).
   - Colete metricas de cobertura.
   - Identifique testes flaky e estabilize.
   - Gere relatorio consolidado.

### Regras:

- Cada criterio de aceitacao deve ter pelo menos 1 teste automatizado.
- Testes E2E devem cobrir 100% dos fluxos criticos.
- Testes devem ser determinísticos (sem flakiness).
- Dados de teste devem ser isolados entre execucoes.
- Tempo total de execucao da suite nao deve exceder o SLA definido.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Strategy | `output/planning/test-strategy.md` | Estrategia e metas de cobertura |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Base para casos de teste |
| Backend Code | `output/implementation/backend/` | Codigo para testar |
| Frontend Code | `output/implementation/frontend/` | Codigo para testar |
| Architecture Design | `output/architecture/architecture-design.md` | Contratos de API |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Cases | `output/quality/test-cases/` | Casos de teste documentados |
| Test Code | `output/quality/automated-tests/` | Codigo dos testes automatizados |
| Test Report | `output/quality/test-report.md` | Relatorio consolidado de testes |

### Estrutura do test-report.md:

```markdown
# Relatorio de Testes — [Nome do Projeto]

## Resumo Executivo
- **Total de testes:** [N]
- **Passaram:** [N] ([X%])
- **Falharam:** [N] ([X%])
- **Ignorados:** [N]
- **Tempo de execucao:** [X minutos]

## Cobertura
| Metrica | Meta | Alcancado | Status |
|---------|------|-----------|--------|
| Cobertura de codigo | 80% | [X%] | OK/NOK |
| Cobertura de branches | 70% | [X%] | OK/NOK |
| Fluxos criticos | 100% | [X%] | OK/NOK |

## Testes de Integracao
[Detalhamento por modulo]

## Testes E2E
[Detalhamento por fluxo]

## Bugs Encontrados
| ID | Descricao | Severidade | Status |
|----|-----------|-----------|--------|
| BUG-001 | [Descricao] | Critico | Aberto |

## Riscos e Recomendacoes
[Lista de riscos identificados]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `qa-engineer`
- **Skills:** `write-test-cases`, `automate-tests`, `run-regression`
- **Timeout:** 45 minutos
- **Retries:** 2

## Quality Gate

Antes de avancar para o Step 13, verifique:

- [ ] Todos os criterios de aceitacao cobertos por testes
- [ ] Testes E2E para 100% dos fluxos criticos
- [ ] Cobertura de codigo dentro da meta
- [ ] Nenhum teste flaky na suite
- [ ] Relatorio de testes gerado
- [ ] Bugs criticos documentados
- [ ] Suite de regressao integrada com CI/CD
