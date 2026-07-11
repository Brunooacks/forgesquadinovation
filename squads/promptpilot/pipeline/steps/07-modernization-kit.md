# Fase 7 — Kit de Modernizacao

## Agentes Responsaveis
**Dev Lucas Backend** + **Arq. Helena Sistemas** (subagent)

## Objetivo
Criar o pacote de prompts curados e templates para modernizacao de software.

## Tasks

### 1. Templates de Migracao de Legado
- Java 8 → Java 17+ (records, sealed classes, text blocks, pattern matching)
- AngularJS → Angular 17+ (standalone components, signals)
- jQuery → React (component-based, hooks)
- Spring Boot 2 → Spring Boot 3 (Jakarta EE, native compilation)
- .NET Framework → .NET 8 (minimal APIs, AOT)
- Python 2 → Python 3 (type hints, async/await)

### 2. Templates de Refactoring
- Aplicar SOLID principles
- Extrair Clean Architecture layers
- Implementar DDD (bounded contexts, aggregates, value objects)
- Aplicar design patterns (Factory, Strategy, Observer, Repository)
- Remover code smells (God class, Feature envy, Long method)

### 3. Templates de Cloud Migration
- Dockerizar aplicacao (multi-stage build, health checks)
- Criar Terraform modules (VPC, ECS/EKS, RDS, S3)
- Kubernetes manifests (deployment, service, ingress, HPA)
- Serverless migration (Lambda/Cloud Functions)
- CI/CD pipeline (GitHub Actions workflow)

### 4. Prompts Curados
Para cada template, criar 2-3 prompts prontos para uso:
- Prompt de analise (avaliar codebase atual)
- Prompt de planejamento (gerar plano de migracao)
- Prompt de execucao (gerar codigo migrado)

### 5. Validacao
- Testar geracao de cada template via LLM
- Validar que output segue formato esperado
- Garantir que contexto de projeto e injetado corretamente

## Output
- Templates em `output/code/prompts/templates/`
- Prompts curados em `output/code/prompts/`
- Testes de validacao
