# Fase 4 — Core Engine + Backend API

## Agente Responsavel
**Dev Lucas Backend** (subagent)

## Objetivo
Implementar o nucleo do sistema: Prompt Registry, Template Engine, LLM Adapter e API REST.

## Tasks

### 1. Setup do Projeto
- Inicializar NestJS project com TypeScript strict
- Configurar Prisma ORM + PostgreSQL
- Configurar ESLint + Prettier
- Configurar Jest para testes

### 2. Prompt Registry
- Service para CRUD de prompts
- Parser de Markdown com frontmatter YAML (gray-matter)
- Indexacao no PostgreSQL (id, title, category, tags, content_hash)
- Sync bidirecional Git <-> DB
- Busca full-text (PostgreSQL tsvector)

### 3. Template Engine
- Parser de templates YAML
- Renderizacao com Handlebars
- Helpers customizados (date, slug, capitalize)
- Validacao de template (schema)

### 4. LLM Adapter
- Interface `LLMAdapter` (generate, enrich, summarize)
- `ClaudeAdapter` usando @anthropic-ai/sdk
- `OpenAIAdapter` usando openai sdk
- Config via env vars (API keys, model selection)
- Rate limiting e retry logic

### 5. API REST
- `PromptsController` — CRUD + search
- `GenerateController` — gerar agente/script
- `CategoriesController` — listar categorias
- `MetricsController` — metricas de uso
- Auth middleware (JWT)
- Global exception filter
- Swagger documentation

### 6. Testes
- Testes unitarios para cada service
- Testes de integracao para controllers
- Mock de LLM calls

## Output
- Codigo fonte em `output/code/backend/`
- Testes em `output/code/backend/test/`
- Prisma schema em `output/code/backend/prisma/`
