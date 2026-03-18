---
step: "16"
name: "Documentacao Tecnica"
type: agent
agent: tech-writer
tasks:
  - write-api-docs
  - write-runbook
  - write-release-notes
depends_on: step-15
phase: documentation
---

# Step 16: Tech Writer — Documentacao Tecnica

## Para o Pipeline Runner

Acione o agente `tech-writer` com as tasks `write-api-docs`, `write-runbook` e
`write-release-notes`. O Tech Writer deve gerar documentacao tecnica completa
para operacao, manutencao e comunicacao do release.

### Instrucoes para o Agente:

1. **Leia** toda a documentacao existente (arquitetura, API, testes, reviews).
2. **Gere** documentacao de API:
   - Descricao de cada endpoint.
   - Parametros de request (query, path, body).
   - Exemplos de response (sucesso e erro).
   - Codigos de status HTTP.
   - Exemplos de uso com curl/httpie.
   - Autenticacao necessaria.
3. **Gere** runbook operacional:
   - Pre-requisitos para deploy.
   - Procedimento de deploy passo a passo.
   - Procedimento de rollback.
   - Health checks e como verificar.
   - Troubleshooting de problemas comuns.
   - Contatos e escalonamento.
   - Monitoramento e alertas.
4. **Gere** release notes:
   - Novas funcionalidades.
   - Melhorias.
   - Bug fixes (se aplicavel).
   - Breaking changes (se aplicavel).
   - Requisitos de migracao.
   - Problemas conhecidos.

### Regras:

- Documentacao deve ser clara para alguem que nao participou do projeto.
- API docs devem ser completas o suficiente para integracao sem suporte.
- Runbook deve permitir deploy por alguem nao familiarizado com o projeto.
- Release notes devem seguir formato changelog padrao.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Referencia arquitetural |
| Backend Code | `output/implementation/backend/` | Codigo fonte para referencia |
| Frontend Code | `output/implementation/frontend/` | Codigo fonte para referencia |
| Test Report | `output/quality/test-report.md` | Resultados de testes |
| Code Review Report | `output/review/code-review-report.md` | Review findings |
| Arch Review Report | `output/review/arch-review-report.md` | Conformidade arquitetural |
| User Stories | `output/requirements/user-stories.md` | Features implementadas |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| API Docs | `output/documentation/api-docs.md` | Documentacao completa da API |
| Runbook | `output/documentation/runbook.md` | Guia operacional de deploy e manutencao |
| Release Notes | `output/documentation/release-notes.md` | Notas de release |

### Estrutura do api-docs.md:

```markdown
# API Documentation — [Nome do Projeto]

## Base URL
[URL base da API]

## Autenticacao
[Metodo de autenticacao]

## Endpoints

### [Modulo 1]

#### GET /api/v1/resource
- **Descricao:** [descricao]
- **Autenticacao:** Requerida
- **Parametros:**
  | Nome | Tipo | Obrigatorio | Descricao |
  |------|------|------------|-----------|
  | id | string | Sim | ID do recurso |
- **Response 200:**
  ```json
  { "data": { ... } }
  ```
- **Response 404:**
  ```json
  { "error": { "code": "NOT_FOUND", "message": "..." } }
  ```
- **Exemplo:** `curl -H "Authorization: Bearer TOKEN" https://api.example.com/v1/resource`
```

### Estrutura do runbook.md:

```markdown
# Runbook — [Nome do Projeto]

## 1. Pre-requisitos
[Lista de pre-requisitos]

## 2. Deploy
### 2.1 Procedimento Padrao
[Passo a passo]

### 2.2 Rollback
[Procedimento de rollback]

## 3. Health Checks
[Como verificar saude do sistema]

## 4. Troubleshooting
| Sintoma | Causa Provavel | Solucao |
|---------|---------------|---------|
| [sintoma] | [causa] | [solucao] |

## 5. Monitoramento e Alertas
[Dashboards e alertas configurados]

## 6. Contatos
[Lista de contatos e escalonamento]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `tech-writer`
- **Skills:** `write-api-docs`, `write-runbook`, `write-release-notes`
- **Timeout:** 30 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 17, verifique:

- [ ] API docs cobrem todos os endpoints
- [ ] Exemplos de request/response presentes
- [ ] Runbook completo com deploy e rollback
- [ ] Troubleshooting documentado
- [ ] Release notes geradas
- [ ] Documentacao revisada para clareza e completude
- [ ] Todos os artefatos nos caminhos corretos
