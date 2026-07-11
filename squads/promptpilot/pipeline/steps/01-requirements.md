# Fase 1 — Levantamento de Requisitos

## Agente Responsavel
**BA Mariana Prompts** (subagent)

## Objetivo
Levantar todos os requisitos funcionais e nao-funcionais do PromptPilot MVP.

## Tasks

### 1. Mapear Categorias de Prompts
Definir a taxonomia completa de categorias:
- **Modernizacao**: migracao de legado, upgrade de frameworks, deprecation fixes
- **Refactoring**: SOLID, Clean Architecture, DDD, design patterns
- **Cloud**: containerizacao, IaC, Kubernetes, serverless
- **Testing**: unit tests, integration, E2E, performance
- **Documentation**: README, API docs, ADRs, runbooks
- **Architecture**: system design, API design, database modeling

### 2. User Stories
Escrever user stories para cada modulo:
- CLI Tool (search, use, generate, list, add)
- Web Dashboard (busca, CRUD, metricas, gerador)
- Core Engine (registry, template engine, LLM adapter)

### 3. Formato de Prompt
Especificar o formato padrao:
```yaml
---
id: unique-id
title: "Titulo do Prompt"
category: modernization
tags: [java, migration, spring-boot]
complexity: medium
target: backend
author: nome
created: 2026-03-18
version: 1.0
---
# Prompt content in Markdown
```

### 4. Criterios de Aceitacao
Definir criterios para cada user story no formato Given-When-Then.

### 5. Personas
Mapear personas de usuario com suas necessidades especificas.

## Output
- `output/requirements/user-stories.md`
- `output/requirements/prompt-taxonomy.md`
- `output/requirements/prompt-format-spec.md`
- `output/requirements/personas.md`
