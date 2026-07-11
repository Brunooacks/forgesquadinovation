# Fase 2 — Design de Arquitetura

## Agente Responsavel
**Arq. Helena Sistemas** (inline)

## Objetivo
Definir a arquitetura completa do PromptPilot MVP.

## Tasks

### 1. Arquitetura do Sistema
Desenhar a arquitetura com 4 camadas:
- **CLI Client**: Node.js CLI que consome a API
- **Web Client**: Next.js dashboard que consome a API
- **API Layer**: NestJS REST API
- **Core Engine**: Prompt Registry + Template Engine + LLM Adapter

### 2. Modelo de Dados
- **Prompts**: armazenados como .md no Git, indexados no PostgreSQL
- **Templates**: YAML files com placeholders Handlebars
- **Users**: PostgreSQL (id, name, email, role, favorites)
- **Metrics**: PostgreSQL (prompt_id, user_id, action, timestamp)

### 3. API Contracts
Definir endpoints REST:
- `GET /api/prompts` — listar/buscar prompts
- `GET /api/prompts/:id` — detalhe do prompt
- `POST /api/prompts` — criar prompt
- `PUT /api/prompts/:id` — atualizar prompt
- `DELETE /api/prompts/:id` — deletar prompt
- `POST /api/generate` — gerar agente/script via template+LLM
- `GET /api/categories` — listar categorias
- `GET /api/metrics` — metricas de uso

### 4. Estrutura do Repositorio Git de Prompts
```
prompts/
  modernization/
    java8-to-17.md
    angularjs-to-angular.md
    ...
  refactoring/
    apply-solid.md
    extract-clean-arch.md
    ...
  cloud/
    dockerize-app.md
    terraform-setup.md
    ...
  templates/
    agent-template.yaml
    migration-script.yaml
    ...
```

### 5. Integracao LLM
- Adapter pattern: `LLMAdapter` interface
- `ClaudeAdapter` (primary) — usa @anthropic-ai/sdk
- `OpenAIAdapter` (fallback) — usa openai sdk
- Template + contexto do projeto → LLM → output enriquecido

### 6. ADRs
Criar ADRs para decisoes chave:
- ADR-001: Git-based storage para prompts
- ADR-002: Hibrido template+LLM para geracao
- ADR-003: NestJS como framework backend
- ADR-004: Commander.js para CLI

## Output
- `output/architecture/system-design.md`
- `output/architecture/data-model.md`
- `output/architecture/api-contracts.md`
- `output/architecture/adrs/`
