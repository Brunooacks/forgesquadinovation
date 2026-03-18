---
step: "07"
name: "Definicao de Estrategia de Testes"
type: agent
agent: qa-engineer
tasks:
  - define-test-strategy
depends_on: step-06
phase: planning
---

# Step 07: QA Engineer — Definicao de Estrategia de Testes

## Para o Pipeline Runner

Acione o agente `qa-engineer` com a task `define-test-strategy`. O QA Engineer
deve definir a estrategia completa de testes para o projeto, cobrindo todos os
niveis da piramide de testes e alinhada com a arquitetura definida.

### Instrucoes para o Agente:

1. **Leia** os requisitos, criterios de aceitacao e arquitetura.
2. **Defina** a piramide de testes:
   - **Testes Unitarios:** Cobertura minima, ferramentas, responsavel.
   - **Testes de Integracao:** Contratos de API, banco de dados, servicos externos.
   - **Testes End-to-End:** Fluxos criticos de negocio.
   - **Testes de Performance:** Carga, estresse, endurance (se aplicavel).
   - **Testes de Seguranca:** OWASP Top 10, autenticacao, autorizacao.
3. **Selecione** ferramentas e frameworks:
   - Framework de testes unitarios.
   - Framework de testes E2E.
   - Ferramenta de performance.
   - Ferramenta de analise de seguranca.
4. **Defina** metas de cobertura:
   - Cobertura minima de codigo (ex: 80%).
   - Cobertura de branches (ex: 70%).
   - Cobertura de fluxos criticos (100%).
5. **Estabeleca** criterios de qualidade:
   - Criterios de aprovacao para cada nivel de teste.
   - Thresholds de performance aceitaveis.
   - SLAs de tempo de execucao dos testes.
6. **Planeje** a automacao:
   - Quais testes serao automatizados.
   - Integracao com CI/CD.
   - Estrategia de dados de teste.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | Requisitos para cobertura |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Base para casos de teste |
| Architecture Design | `output/architecture/architecture-design.md` | Componentes a testar |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Tarefas planejadas |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Strategy | `output/planning/test-strategy.md` | Estrategia completa de testes |

### Estrutura do test-strategy.md:

```markdown
# Estrategia de Testes — [Nome do Projeto]

## 1. Piramide de Testes
### 1.1 Testes Unitarios
- Cobertura minima: [X%]
- Ferramentas: [lista]
- Responsavel: [agente]

### 1.2 Testes de Integracao
- Escopo: [descricao]
- Ferramentas: [lista]

### 1.3 Testes E2E
- Fluxos criticos: [lista]
- Ferramentas: [lista]

### 1.4 Testes de Performance
- Cenarios: [lista]
- Ferramentas: [lista]
- Thresholds: [metricas]

### 1.5 Testes de Seguranca
- Checklist OWASP: [itens]
- Ferramentas: [lista]

## 2. Metas de Cobertura
| Metrica | Meta | Minimo Aceitavel |
|---------|------|-----------------|
| Cobertura de codigo | 80% | 70% |
| Cobertura de branches | 70% | 60% |
| Fluxos criticos | 100% | 100% |

## 3. Ferramentas e Frameworks
[Tabela de ferramentas]

## 4. Automacao e CI/CD
[Estrategia de integracao]

## 5. Dados de Teste
[Estrategia de geracao e manutencao]

## 6. Criterios de Aprovacao
[Definicao de done para cada nivel]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `qa-engineer`
- **Skills:** `define-test-strategy`
- **Timeout:** 20 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 08, verifique:

- [ ] Todos os niveis da piramide de testes definidos
- [ ] Ferramentas selecionadas para cada nivel
- [ ] Metas de cobertura estabelecidas
- [ ] Fluxos criticos identificados para E2E
- [ ] Estrategia de automacao documentada
- [ ] Criterios de aprovacao claros
- [ ] Estrategia de dados de teste definida
- [ ] Integracao com CI/CD planejada
