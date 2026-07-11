# Fase 8 — Testing & QA

## Agente Responsavel
**QA Priscila Test** (subagent)

## Objetivo
Garantir qualidade do MVP com cobertura de testes abrangente.

## Tasks

### 1. Testes Unitarios — Core Engine
- PromptRegistry: CRUD, search, sync
- TemplateEngine: parsing, rendering, validation
- LLMAdapter: generate, enrich (com mocks)
- Cobertura minima: 80%

### 2. Testes de Integracao — API
- Todos os endpoints (CRUD prompts, generate, categories, metrics)
- Auth (JWT valid, invalid, expired)
- Error handling (404, 400, 500)
- Paginacao e filtros

### 3. Testes E2E — CLI
- `promptpilot search` (com resultados, sem resultados)
- `promptpilot use` (prompt existente, inexistente)
- `promptpilot generate` (template valido, contexto invalido)
- `promptpilot list` (todas categorias, categoria especifica)
- `promptpilot config` (setup, reset)

### 4. Testes E2E — Web Dashboard
- Fluxo de busca (digitar, filtrar, clicar resultado)
- Fluxo de CRUD (criar, editar, deletar prompt)
- Fluxo do Gerador (wizard completo, download)
- Dashboard de metricas (graficos renderizam, dados corretos)
- Responsividade (desktop, tablet, mobile)

### 5. Testes de Geracao
- Template + LLM gera output valido
- Output segue formato esperado (frontmatter + body)
- Contexto de projeto e injetado corretamente
- Fallback de LLM funciona (Claude → OpenAI)

### 6. Report
- Coverage report consolidado
- Lista de bugs encontrados com severidade
- Recomendacoes de melhoria

## Output
- Test suites em cada modulo
- `output/qa/coverage-report.md`
- `output/qa/bug-report.md`
- `output/qa/test-execution-report.md`
