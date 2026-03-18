---
step: "02"
name: "Elicitacao de Requisitos"
type: agent
agent: business-analyst
tasks:
  - elicit-requirements
  - write-user-stories
depends_on: step-01
phase: requirements
---

# Step 02: Business Analyst — Elicitacao de Requisitos

## Para o Pipeline Runner

Acione o agente `business-analyst` com as tasks `elicit-requirements` e `write-user-stories`.
O agente deve analisar o project brief e produzir user stories completas com criterios
de aceitacao, priorizadas por valor de negocio.

### Instrucoes para o Agente:

1. **Leia** o arquivo `output/requirements/project-brief.md` completamente.
2. **Identifique** os epicos principais a partir dos objetivos de negocio.
3. **Decomponha** cada epico em user stories no formato:
   - "Como [persona], eu quero [acao] para que [beneficio]."
4. **Escreva** criterios de aceitacao para cada user story no formato Given/When/Then.
5. **Priorize** usando MoSCoW (Must/Should/Could/Won't).
6. **Identifique** dependencias entre stories.
7. **Mapeie** requisitos nao-funcionais como cross-cutting concerns.

### Regras:

- Cada user story deve ser independente, negociavel, valiosa, estimavel, pequena e testavel (INVEST).
- Criterios de aceitacao devem ser verificaveis e automatizaveis.
- Inclua user stories para fluxos de erro e edge cases.
- Considere acessibilidade e internacionalizacao quando aplicavel.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Project Brief | `output/requirements/project-brief.md` | Briefing completo do projeto |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | Lista completa de user stories priorizadas |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios de aceitacao detalhados por story |

### Estrutura do user-stories.md:

```markdown
# User Stories — [Nome do Projeto]

## Epico 1: [Nome]
### US-001: [Titulo]
- **Como** [persona]
- **Quero** [acao]
- **Para que** [beneficio]
- **Prioridade:** Must Have
- **Estimativa:** [story points]
- **Dependencias:** [lista]

## Epico 2: [Nome]
...
```

### Estrutura do acceptance-criteria.md:

```markdown
# Criterios de Aceitacao — [Nome do Projeto]

## US-001: [Titulo]
### AC-001.1: [Cenario]
- **Given** [contexto]
- **When** [acao]
- **Then** [resultado esperado]

### AC-001.2: [Cenario de erro]
- **Given** [contexto]
- **When** [acao invalida]
- **Then** [tratamento de erro]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `business-analyst`
- **Skills:** `elicit-requirements`, `write-user-stories`
- **Timeout:** 30 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 03, verifique:

- [ ] Todas as user stories seguem o formato padrao
- [ ] Cada story tem pelo menos 2 criterios de aceitacao
- [ ] Stories estao priorizadas (MoSCoW)
- [ ] Requisitos nao-funcionais estao mapeados
- [ ] Nao ha ambiguidade nos criterios de aceitacao
- [ ] Fluxos de erro foram considerados
- [ ] Dependencias entre stories estao identificadas
- [ ] Arquivos gerados nos caminhos corretos
