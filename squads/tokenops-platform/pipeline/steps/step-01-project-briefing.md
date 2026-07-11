---
step: "01"
name: "Briefing do Projeto TokenOps"
type: checkpoint
depends_on: null
phase: requirements
---

# Step 01: Briefing do Projeto TokenOps

## Para o Pipeline Runner

Este checkpoint coleta todas as informacoes fundamentais do projeto TokenOps antes de iniciar qualquer trabalho de engenharia. O Pipeline Runner deve apresentar cada bloco de perguntas ao usuario e aguardar respostas completas antes de avancar.

### Blocos de perguntas a coletar:

1. **Produto e Visao**: Nome do produto (TokenOps Platform), versao alvo (MVP v1.0), missao (FinOps inteligente para AI), proposta de valor unica.

2. **Escopo dos 6 Modulos**:
   - AI Gateway (proxy inteligente para LLMs) — MVP
   - Token Estimator (estimativa pre-execucao de tokens e custos) — MVP
   - Model Recommendation Engine (recomendacao de modelo por task) — MVP
   - Prompt Optimization Engine (otimizacao automatica de prompts) — V2
   - Remediation Engine (acoes corretivas automaticas) — V2
   - Dashboard de Governanca (visibilidade e controle de custos) — MVP
   - Confirmar priorizacao MVP vs V2/V3.

3. **Plugins**:
   - Chrome Extension (estimativa inline em playgrounds) — V2
   - VS Code Extension (estimativa e recomendacao no editor) — V2

4. **KPIs de Negocio**: Metas de reducao de custo com LLMs (ex: 30-40%), tempo medio de payback, metricas de adocao (DAU, MAU), churn targets por plano.

5. **Publico-Alvo**: AI Engineers, Engineering Managers, FinOps Analysts, Platform Admins, Developers. Tamanho de empresa alvo, maturidade em AI.

6. **Restricoes**:
   - Timeline: MVP em 3 meses
   - Regulacoes: LGPD, SOC2 compliance path
   - Budget e equipe disponivel
   - Restricoes tecnicas (cloud provider, regiao)

7. **Tech Stack Confirmacao**:
   - Backend: NestJS (Node.js)
   - Frontend: Next.js (React)
   - OLTP Database: PostgreSQL
   - OLAP Database: ClickHouse
   - Cache/Queue: Redis
   - Confirmar ou ajustar.

8. **Integracoes LLM**: OpenAI, Anthropic, Gemini, Azure OpenAI, AWS Bedrock, Groq, DeepSeek. Confirmar prioridade de integracao para MVP (minimo 3 providers).

9. **NFRs (Requisitos Nao-Funcionais)**:
   - Latencia do proxy: <50ms overhead
   - Throughput: 10.000+ req/s
   - Disponibilidade: 99.9% SLA
   - Tempo de resposta do dashboard: <2s
   - Retencao de dados analytics: 90 dias (Starter), 1 ano (Pro), 2 anos (Enterprise)

10. **Modelo de Precificacao**:
    - Starter: $29/mo (ate 100k tokens monitorados)
    - Pro: $199/mo (ate 10M tokens, analytics avancado)
    - Enterprise: $1.000+/mo (ilimitado, SSO, SLA dedicado)
    - Modelo alternativo: pay-per-token-saved (porcentagem da economia gerada)

11. **Cenario Competitivo**: Helicone, LiteLLM, Portkey, LangSmith, Datadog LLM Observability. Diferenciais do TokenOps.

### Quality Gate

Antes de avancar para o Step 02, validar:
- [ ] Todos os blocos de perguntas respondidos
- [ ] Priorizacao MVP vs V2/V3 confirmada
- [ ] Tech stack aprovado
- [ ] KPIs de negocio definidos com metas numericas
- [ ] NFRs com valores especificos
- [ ] Restricoes de timeline e compliance documentadas
- [ ] Modelo de precificacao validado

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| company.md | `_forgesquad/_memory/company.md` | Contexto da empresa e preferencias |
| squad config | `squads/tokenops-platform/squad.yaml` | Configuracao do squad |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Project Brief | `output/requirements/project-brief.md` | Documento completo com todas as respostas do briefing, decisoes tomadas e escopo confirmado |

### Estrutura do project-brief.md

```
# TokenOps Platform — Project Brief
## 1. Visao do Produto
## 2. Escopo dos Modulos (MVP vs V2/V3)
## 3. Plugins
## 4. KPIs de Negocio
## 5. Publico-Alvo e Personas
## 6. Restricoes
## 7. Tech Stack
## 8. Integracoes LLM
## 9. Requisitos Nao-Funcionais
## 10. Modelo de Precificacao
## 11. Cenario Competitivo
## 12. Decisoes e Premissas
```

## Execution Mode

- **Tipo**: Checkpoint (interativo)
- **Requer input do usuario**: Sim — respostas a todos os blocos de perguntas
- **Automatizavel**: Nao — depende de decisoes humanas
- **Tempo estimado**: 30-60 minutos de sessao com stakeholder

## Quality Gate

- [ ] Documento project-brief.md gerado e completo
- [ ] Nenhum campo critico em branco
- [ ] Stakeholder confirmou o conteudo
- [ ] Escopo MVP claramente delimitado (4 modulos: Gateway, Token Estimator, Model Recommendation, Dashboard)
- [ ] Aprovacao explicita do usuario para prosseguir
