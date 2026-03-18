---
step: "15"
name: "Revisao Arquitetural do Codigo"
type: agent
agent: architect
tasks:
  - review-architecture
depends_on: step-14
phase: review
---

# Step 15: Architect — Revisao Arquitetural do Codigo

## Para o Pipeline Runner

Acione o agente `architect` com a task `review-architecture`. O Arquiteto
verifica se o codigo implementado segue fielmente a arquitetura definida
e se as decisoes arquiteturais (ADRs) foram respeitadas.

### Instrucoes para o Agente:

1. **Leia** a arquitetura definida e todas as ADRs.
2. **Compare** a implementacao com o design:

   **a) Conformidade Estrutural:**
   - Componentes implementados conforme diagrama C4?
   - Separacao de responsabilidades respeitada?
   - Camadas de abstracao corretas?
   - Dependencias entre modulos conforme planejado?

   **b) Conformidade com ADRs:**
   - Cada ADR foi implementada corretamente?
   - Alguma decisao foi subvertida ou ignorada?
   - Novas decisoes foram tomadas sem ADR?

   **c) Contratos de API:**
   - Endpoints implementados conforme especificacao?
   - Payloads de request/response corretos?
   - Versionamento de API adequado?
   - Codigos de erro padronizados?

   **d) Modelagem de Dados:**
   - Entidades conforme diagrama ER?
   - Relacionamentos corretos?
   - Indices adequados?
   - Migrations reversiveis?

   **e) Requisitos Nao-Funcionais:**
   - Escalabilidade: preparado para escalar?
   - Seguranca: modelo implementado?
   - Observabilidade: logs, metricas, traces?
   - Resiliencia: circuit breaker, retry, fallback?

   **f) Divida Tecnica:**
   - Identificar divida tecnica introduzida.
   - Classificar por prioridade de resolucao.
   - Documentar impacto e sugestao de correcao.

3. **Emita** veredito arquitetural: CONFORME, PARCIALMENTE CONFORME, NAO CONFORME.

### Regras:

- Desvios da arquitetura devem ser justificados com nova ADR.
- Se NAO CONFORME, retorne ao Step 09 com instrucoes de correcao.
- Divida tecnica aceitavel deve ser documentada para resolucao futura.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Design original |
| ADRs | `output/architecture/adrs/` | Decisoes arquiteturais |
| Backend Code | `output/implementation/backend/` | Codigo backend |
| Frontend Code | `output/implementation/frontend/` | Codigo frontend |
| Code Review Report | `output/review/code-review-report.md` | Findings do Tech Lead |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Arch Review Report | `output/review/arch-review-report.md` | Relatorio de conformidade arquitetural |

### Estrutura do arch-review-report.md:

```markdown
# Revisao Arquitetural — [Nome do Projeto]

## Veredito: [CONFORME / PARCIALMENTE CONFORME / NAO CONFORME]
- **Data:** [data]
- **Revisor:** architect

## Conformidade Estrutural
| Componente | Status | Observacao |
|-----------|--------|-----------|
| [Componente 1] | Conforme | - |
| [Componente 2] | Desvio | [descricao] |

## Conformidade com ADRs
| ADR | Titulo | Status | Observacao |
|-----|--------|--------|-----------|
| ADR-001 | [titulo] | Implementada | - |
| ADR-002 | [titulo] | Desvio | [descricao] |

## Contratos de API
[Validacao de conformidade]

## Modelagem de Dados
[Validacao de conformidade]

## Requisitos Nao-Funcionais
[Checklist de conformidade]

## Divida Tecnica Identificada
| ID | Descricao | Prioridade | Impacto |
|----|-----------|-----------|---------|
| TD-001 | [descricao] | Alta | [impacto] |

## Recomendacoes
[Lista de acoes recomendadas]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `architect`
- **Skills:** `review-architecture`
- **Timeout:** 30 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 16, verifique:

- [ ] Todos os componentes verificados contra a arquitetura
- [ ] Conformidade com ADRs validada
- [ ] Contratos de API verificados
- [ ] Veredito: CONFORME ou PARCIALMENTE CONFORME (com justificativa)
- [ ] Divida tecnica documentada
- [ ] Relatorio de revisao arquitetural gerado
