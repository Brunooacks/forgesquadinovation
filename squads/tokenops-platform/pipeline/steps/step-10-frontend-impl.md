---
step: "10"
name: "Implementacao Frontend — Dashboard, Estimator UI, Recommendation UI"
type: agent
agent: dev-frontend
tasks:
  - implement-ui
  - integrate-api
  - write-component-tests
depends_on: step-09
phase: implementation
---

# Step 10: Implementacao Frontend — Dashboard, Estimator UI, Recommendation UI

## Para o Pipeline Runner

O agente Developer Frontend deve implementar toda a camada frontend do TokenOps Platform MVP usando Next.js App Router, integrando com as APIs backend do Step 09. A implementacao deve cobrir o Dashboard de Governanca, Token Estimator UI, Model Recommendation UI, Cost Explorer e Settings.

### Componentes a implementar:

1. **Next.js App Router Project Setup**:
   - Next.js 14+ com App Router
   - Tailwind CSS para estilizacao
   - Dark mode support (tema claro/escuro)
   - Layout responsivo (desktop, tablet, mobile)
   - React Query (TanStack Query) para data fetching e cache
   - Recharts para graficos e visualizacoes
   - Zustand ou Context API para state management
   - Autenticacao (NextAuth.js ou similar, integrando com JWT backend)

2. **Dashboard de Governanca (pagina principal)**:
   - **Cards de resumo**: Total tokens consumidos, custo total (periodo), custo medio por request, economia gerada
   - **Custo por modelo**: Grafico de barras/pizza com breakdown por modelo (GPT-4, Claude, Gemini, etc.)
   - **Custo por projeto**: Grafico de barras com breakdown por projeto/equipe
   - **Top prompts caros**: Tabela com os prompts mais caros (hash, modelo, custo, frequencia)
   - **Economia potencial**: Widget mostrando quanto poderia ser economizado com model recommendation e prompt optimization
   - **Tendencias**: Grafico de linha com custo ao longo do tempo (diario, semanal, mensal)
   - **Real-time updates**: WebSocket para atualizar dashboard sem refresh
   - Filtros globais: periodo, equipe, projeto, modelo, provider

3. **Token Estimator UI**:
   - **Prompt input**: Text area para colar/digitar prompt
   - **Model selection**: Dropdown com todos os modelos disponiveis (agrupados por provider)
   - **Estimativa de custo**: Card com tokens de input estimados, tokens de output estimados, custo total estimado
   - **Comparacao multi-modelo**: Tabela comparando custo do mesmo prompt em diferentes modelos
   - **Historico de estimativas**: Lista das ultimas estimativas realizadas

4. **Model Recommendation UI**:
   - **Task description**: Text area para descrever a tarefa
   - **Parametros de scoring**: Sliders/selects para complexidade, criticidade, latencia, budget
   - **Recomendacao com ranking**: Lista ranqueada de modelos com score, custo estimado, latencia media
   - **Explicabilidade**: Tooltip/expandable com razao da recomendacao de cada modelo
   - **Quick action**: Botao para testar o modelo recomendado direto no Token Estimator

5. **Cost Explorer**:
   - **Filtros avancados**: Por equipe, projeto, modelo, provider, periodo customizado
   - **Visualizacoes**: Graficos de linha (tendencia), barras (comparacao), tabela detalhada
   - **Drill-down**: Clicar em um ponto para ver detalhes (requests individuais)
   - **Export**: Download CSV dos dados filtrados
   - **Periodo**: Date range picker com presets (7d, 30d, 90d, custom)

6. **Settings**:
   - **Organization management**: Nome, slug, plano atual, limites
   - **Team management**: CRUD de equipes, membros, permissoes
   - **API Keys**: Gerar, revogar, copiar, ver uso por key
   - **Plans & Billing**: Plano atual, upgrade/downgrade, historico de faturas (Stripe)
   - **Integrations**: Configurar API keys dos LLM providers
   - **Preferences**: Tema (dark/light), notificacoes, timezone

### Design System:

- Tailwind CSS com design tokens customizados
- Componentes reutilizaveis: Card, Table, Chart, Modal, Dropdown, DatePicker, Slider
- Dark mode como default para publico de engenheiros
- Acessibilidade (WCAG 2.1 AA)
- Loading states, empty states, error states para todos os componentes

### Integracao com Backend:

- React Query para todas as chamadas API
- Interceptor para autenticacao (JWT token)
- WebSocket connection para real-time dashboard
- Error handling global (toast notifications)
- Retry e cache strategies (stale-while-revalidate)

## Inputs para este Step

| Artifact | Fonte | Descricao |
|----------|-------|-----------|
| Backend APIs | `output/implementation/backend/api-contracts.md` | Endpoints REST para integracao |
| Architecture Design | `output/architecture/architecture-design.md` | Design de referencia |
| User Stories | `output/requirements/user-stories.md` | Stories MVP de frontend |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Criterios para validar UI |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Sequencia de implementacao |
| Test Strategy | `output/planning/test-strategy.md` | Diretrizes de testes (Playwright, component tests) |

## Expected Outputs

| Artifact | Caminho | Descricao |
|----------|---------|-----------|
| Frontend Source | `output/implementation/frontend/` | Codigo fonte Next.js completo |
| Component Catalog | `output/implementation/frontend/component-catalog.md` | Catalogo de componentes reutilizaveis |
| Test Results | `output/implementation/frontend/test-results.md` | Relatorio de testes de componentes |

### Estrutura de `output/implementation/frontend/`

```
frontend/
  app/
    (auth)/
      login/
      register/
    (dashboard)/
      page.tsx            # Dashboard de Governanca
      estimator/          # Token Estimator UI
      recommendation/     # Model Recommendation UI
      explorer/           # Cost Explorer
      settings/           # Settings (org, teams, keys, billing)
    layout.tsx
    providers.tsx
  components/
    ui/                   # Design system (Card, Table, Chart, etc.)
    dashboard/            # Dashboard-specific components
    estimator/            # Estimator-specific components
    recommendation/       # Recommendation-specific components
    explorer/             # Explorer-specific components
    settings/             # Settings-specific components
  hooks/                  # Custom hooks (useAuth, useWebSocket, etc.)
  lib/                    # Utils, API client, constants
  styles/                 # Tailwind config, global styles
  __tests__/              # Component tests
  component-catalog.md
  test-results.md
```

## Execution Mode

- **Tipo**: Agent (dev-frontend)
- **Requer input do usuario**: Nao — agente implementa autonomamente com base nos artifacts
- **Automatizavel**: Sim
- **Tempo estimado**: 35-50 minutos de execucao do agente

## Quality Gate

- [ ] Next.js App Router project funcional
- [ ] Dashboard de Governanca com todos os widgets (tokens, custos, tendencias, top prompts, economia)
- [ ] Token Estimator UI com input, model selection, estimativa e comparacao multi-modelo
- [ ] Model Recommendation UI com task description, parametros, ranking e explicabilidade
- [ ] Cost Explorer com filtros avancados e visualizacoes
- [ ] Settings com org management, teams, API keys, billing
- [ ] Recharts implementado para todos os graficos
- [ ] React Query integrando com todas as APIs backend
- [ ] Dark mode funcional
- [ ] Responsive design (desktop, tablet, mobile)
- [ ] Component tests passando
- [ ] Loading, empty e error states implementados
- [ ] WebSocket para real-time dashboard updates
- [ ] Acessibilidade basica (WCAG 2.1 AA)
