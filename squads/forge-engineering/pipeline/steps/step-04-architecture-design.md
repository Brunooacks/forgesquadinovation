---
step: "04"
name: "Design de Arquitetura"
type: agent
agent: architect
tasks:
  - design-architecture
  - create-adr
depends_on: step-03
phase: architecture
---

# Step 04: Architect — Design de Arquitetura

## Para o Pipeline Runner

Acione o agente `architect` com as tasks `design-architecture` e `create-adr`.
O Arquiteto deve produzir um documento de arquitetura completo e ADRs para cada
decisao significativa, baseando-se nos requisitos aprovados.

### Instrucoes para o Agente:

1. **Leia** os requisitos aprovados (`user-stories.md`, `acceptance-criteria.md`).
2. **Leia** o project brief para contexto de restricoes e stack tecnologica.
3. **Defina** o estilo arquitetural (monolito, microservicos, serverless, etc.).
4. **Projete** os componentes principais:
   - Diagrama de contexto (C4 Level 1)
   - Diagrama de containers (C4 Level 2)
   - Diagrama de componentes (C4 Level 3) para modulos criticos
5. **Defina** a modelagem de dados (entidades principais e relacionamentos).
6. **Especifique** contratos de API (endpoints, metodos, payloads).
7. **Enderece** requisitos nao-funcionais:
   - Estrategia de escalabilidade
   - Modelo de seguranca (autenticacao, autorizacao)
   - Estrategia de observabilidade (logs, metricas, traces)
   - Estrategia de resiliencia (circuit breaker, retry, fallback)
8. **Crie ADRs** para cada decisao arquitetural significativa.

### Regras:

- Cada ADR deve seguir o formato: Titulo, Status, Contexto, Decisao, Consequencias.
- Diagramas devem ser descritos em formato Mermaid ou PlantUML.
- A arquitetura deve ser justificada em relacao aos requisitos.
- Trade-offs devem ser documentados explicitamente.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | Requisitos aprovados |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios de aceitacao |
| Project Brief | `output/requirements/project-brief.md` | Restricoes e preferencias tecnicas |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Documento completo de arquitetura |
| ADRs | `output/architecture/adrs/adr-NNN-*.md` | Architecture Decision Records |

### Estrutura do architecture-design.md:

```markdown
# Arquitetura — [Nome do Projeto]

## 1. Visao Geral
[Estilo arquitetural e justificativa]

## 2. Diagrama de Contexto (C4 L1)
[Mermaid diagram]

## 3. Diagrama de Containers (C4 L2)
[Mermaid diagram]

## 4. Componentes Criticos (C4 L3)
[Mermaid diagram por modulo]

## 5. Modelagem de Dados
[Entidades, relacionamentos, diagrama ER]

## 6. Contratos de API
[Endpoints, metodos, request/response]

## 7. Requisitos Nao-Funcionais
### 7.1 Escalabilidade
### 7.2 Seguranca
### 7.3 Observabilidade
### 7.4 Resiliencia

## 8. Stack Tecnologica
[Tecnologias escolhidas com justificativa]

## 9. Trade-offs
[Decisoes e suas consequencias]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `architect`
- **Skills:** `design-architecture`, `create-adr`
- **Timeout:** 45 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 05, verifique:

- [ ] Estilo arquitetural definido e justificado
- [ ] Diagramas C4 (pelo menos L1 e L2) presentes
- [ ] Modelagem de dados documentada
- [ ] Contratos de API especificados
- [ ] Requisitos nao-funcionais enderecados
- [ ] Pelo menos 3 ADRs criados
- [ ] Trade-offs documentados
- [ ] Stack tecnologica alinhada com restricoes do briefing
