---
step: "01"
name: "Briefing do Projeto TokenOps"
type: checkpoint
depends_on: null
phase: requirements
---

# Step 01: Checkpoint — Briefing do Projeto TokenOps

## Para o Pipeline Runner

Este e o primeiro passo da pipeline. Solicite ao usuario as informacoes do projeto
TokenOps antes de qualquer trabalho dos agentes. Nenhum agente deve ser acionado ate
que o briefing esteja completo e confirmado.

O TokenOps e uma plataforma SaaS de AI FinOps com 6 modulos:
1. **AI Gateway** — Proxy inteligente para chamadas LLM
2. **Dashboard** — Painel de controle e metricas de uso
3. **Token Estimation** — Motor de estimativa de tokens antes do envio
4. **Model Recommendation** — Recomendacao de modelo otimo custo/qualidade
5. **Cost Explorer** — Explorador de custos detalhado por time/projeto/modelo
6. **Alerts & Budgets** — Sistema de alertas e orcamentos por equipe

O MVP cobre: Gateway + Dashboard + Token Estimation + Model Recommendation.

### Perguntas a fazer ao usuario:

1. **Nome do Projeto** — Confirmar "TokenOps" e versao/release alvo.
2. **Descricao** — Validar o escopo dos 6 modulos e prioridade MVP.
3. **Objetivos de Negocio** — Quais KPIs de reducao de custo LLM? Meta de economia para clientes?
4. **Publico-alvo** — Empresas AI-first, fintechs, startups — validar segmentos.
5. **Restricoes** — Orcamento, prazo, regulamentacoes (LGPD, SOC2), provedores LLM suportados.
6. **Preferencias Tecnologicas** — Confirmar NestJS, Next.js, PostgreSQL, ClickHouse, Redis.
7. **Integracoes** — Quais provedores LLM (OpenAI, Anthropic, Google, AWS Bedrock, Azure OpenAI)?
8. **Requisitos Nao-Funcionais** — Latencia maxima do proxy, throughput de requests, SLAs.
9. **Modelo de Precificacao** — Free tier, planos pagos, limites por plano.
10. **Contexto Adicional** — Concorrentes analisados, documentacao de referencia.

### Comportamento do Checkpoint:

- Apresente as perguntas ao usuario de forma conversacional.
- Permita que o usuario responda de forma parcial e complete iterativamente.
- Quando todas as informacoes essenciais (1-7) estiverem coletadas, apresente um resumo.
- Solicite confirmacao explicita: "O briefing esta correto? Posso prosseguir?"
- Somente apos confirmacao, gere o artefato e avance para o proximo step.

## Inputs para este Step

- Nenhum (este e o ponto de entrada da pipeline).

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Project Brief | `output/requirements/project-brief.md` | Documento estruturado com todas as informacoes coletadas do briefing TokenOps |

### Estrutura do project-brief.md:

```markdown
# Project Brief: TokenOps — AI FinOps Platform

## Visao Geral
[Descricao da plataforma e seus 6 modulos]

## Escopo MVP
- AI Gateway (proxy inteligente)
- Dashboard (metricas e controle)
- Token Estimation (estimativa pre-envio)
- Model Recommendation (custo/qualidade otimo)

## Escopo Futuro (pos-MVP)
- Cost Explorer
- Alerts & Budgets

## Objetivos de Negocio
- [KPIs de reducao de custo]
- [Metas de economia]

## Publico-Alvo
[Segmentos de clientes]

## Restricoes
- Prazo: [prazo]
- Orcamento: [orcamento]
- Regulamentacoes: [LGPD, SOC2, etc.]

## Stack Tecnologica
- Backend: Node.js + NestJS (TypeScript)
- Frontend: Next.js + React + Tailwind CSS
- Banco de Dados: PostgreSQL + ClickHouse + Redis
- Observabilidade: OpenTelemetry + Prometheus + Grafana
- CI/CD: GitHub Actions

## Integracoes LLM
- OpenAI (GPT-4, GPT-3.5)
- Anthropic (Claude)
- Google (Gemini)
- AWS Bedrock
- Azure OpenAI

## Requisitos Nao-Funcionais
- Latencia do proxy: [meta]
- Throughput: [requests/s]
- Disponibilidade: [SLA]
- Seguranca: [requisitos]

## Modelo de Precificacao
[Planos e limites]

## Contexto Adicional
[Referencias e concorrentes]
```

## Execution Mode

- **Modo:** Interativo (checkpoint humano)
- **Agente:** Nenhum — interacao direta com o usuario
- **Skills:** Nenhuma

## Quality Gate

Antes de avancar para o Step 02, verifique:

- [ ] Nome do projeto e versao MVP confirmados
- [ ] Escopo dos 6 modulos validado com prioridade MVP
- [ ] Objetivos de negocio e KPIs claros
- [ ] Publico-alvo identificado
- [ ] Restricoes documentadas (prazo, regulamentacoes)
- [ ] Stack tecnologica confirmada (NestJS, Next.js, PostgreSQL, ClickHouse, Redis)
- [ ] Provedores LLM a integrar definidos
- [ ] Requisitos nao-funcionais do proxy documentados
- [ ] Arquivo `project-brief.md` gerado
- [ ] Usuario confirmou o briefing explicitamente
