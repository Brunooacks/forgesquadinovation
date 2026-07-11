---
step: "12"
name: "Testes Automatizados — Gateway, Estimator, Recommender, Dashboard"
type: agent
agent: qa-engineer
tasks:
  - write-test-cases
  - automate-tests
  - run-regression
depends_on: step-11
phase: quality
---

# Step 12: Testes Automatizados — Gateway, Estimator, Recommender, Dashboard

## Para o Pipeline Runner

O QA Engineer escreve e executa testes automatizados para todos os modulos MVP do TokenOps. O Pipeline Runner deve invocar o agente qa-engineer com as tasks na ordem definida: primeiro escrever os casos de teste, depois automatizar, e por fim rodar a suite de regressao completa.

### Escopo de testes:

1. **Testes Unitarios — Backend**:
   - Gateway: logica de proxy (roteamento, retry, fallback), middleware de autenticacao, rate limiting, request/response transformation
   - Token Estimator: precisao da estimativa por modelo (GPT-4, Claude, Gemini), cache de tokenizers, calculo de custo
   - Model Recommendation Engine: algoritmo de scoring (custo vs latencia vs qualidade), ranking de modelos, filtros por capacidade
   - LLM Adapter contracts: interface uniforme para cada provider, tratamento de erros, timeouts

2. **Testes de Integracao — API**:
   - Fluxo completo: request -> Gateway -> LLM Provider -> response -> analytics write
   - Estimator API: POST /v1/estimate com diferentes modelos e prompts
   - Recommender API: POST /v1/recommend com diferentes task types
   - Analytics API: GET /v1/analytics/usage com filtros de data e provider
   - Autenticacao e autorizacao: API keys validas/invalidas, limites por tenant

3. **Testes E2E — Frontend**:
   - Dashboard: carregamento de dados, graficos de custo, filtros de periodo
   - Estimator UI: submissao de prompt, exibicao de estimativa, comparacao entre modelos
   - Recommendation UI: selecao de task type, exibicao de recomendacoes rankeadas
   - Cost Explorer: navegacao por periodos, drill-down por provider/modelo
   - Settings: configuracao de API keys, definicao de limites de gasto

4. **Testes de Contrato — LLM Adapters**:
   - OpenAI adapter: chat completions, embeddings, error handling
   - Anthropic adapter: messages API, streaming, error handling
   - Gemini adapter: generate content, error handling
   - Azure OpenAI adapter: deployment-based routing, error handling
   - Bedrock adapter: invoke model, error handling
   - Groq adapter: chat completions, error handling
   - DeepSeek adapter: chat completions, error handling

5. **Meta de Cobertura**: 80%+ de cobertura de codigo nos modulos MVP.

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Test strategy | `output/quality/test-strategy.md` | Estrategia de testes definida pelo QA |
| Backend source code | `output/implementation/` | Codigo dos modulos backend |
| Frontend source code | `output/implementation/` | Codigo das paginas frontend |
| API contracts | `output/architecture/api-contracts.md` | Contratos de API para validacao |
| Implementation report | `output/reports/impl-checkpoint-report.md` | Status da implementacao aprovado no step-11 |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Test Report | `output/quality/test-report.md` | Relatorio completo de testes com resultados, cobertura, falhas e recomendacoes |

### Estrutura do test-report.md

```
# TokenOps Platform — Test Report
## 1. Resumo Executivo
## 2. Testes Unitarios — Resultados
### 2.1 Gateway
### 2.2 Token Estimator
### 2.3 Model Recommendation Engine
### 2.4 LLM Adapters
## 3. Testes de Integracao — Resultados
## 4. Testes E2E — Resultados
## 5. Testes de Contrato — Resultados
## 6. Cobertura de Codigo
## 7. Falhas e Bugs Encontrados
## 8. Recomendacoes
```

## Execution Mode

- **Tipo**: Agent (automatizado)
- **Agente**: qa-engineer
- **Tasks**: write-test-cases, automate-tests, run-regression
- **Automatizavel**: Sim — execucao sequencial das tasks pelo agente
- **Tempo estimado**: 4-6 horas de execucao

## Quality Gate

- [ ] Testes unitarios escritos para todos os modulos MVP (Gateway, Estimator, Recommender)
- [ ] Testes de integracao cobrindo todos os endpoints de API
- [ ] Testes E2E cobrindo fluxos criticos do frontend (dashboard, estimativa, recomendacao)
- [ ] Testes de contrato para todos os 7 LLM adapters
- [ ] Cobertura de codigo >= 80% nos modulos MVP
- [ ] Todos os testes passando (zero falhas criticas)
- [ ] Relatorio test-report.md gerado com resultados consolidados
