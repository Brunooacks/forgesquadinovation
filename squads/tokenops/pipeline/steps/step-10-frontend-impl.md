---
step: "10"
name: "Implementacao Frontend — Next.js Dashboard & Cost Explorer"
type: agent
agent: dev-frontend
tasks:
  - implement-ui
  - integrate-api
  - write-component-tests
depends_on: step-09
phase: implementation
---

# Step 10: Dev Frontend — Implementacao Frontend TokenOps

## Para o Pipeline Runner

Acione o agente `dev-frontend` com as tasks `implement-ui`, `integrate-api` e
`write-component-tests`. O desenvolvedor frontend deve implementar o Dashboard
TokenOps em Next.js, integrando com as APIs do backend para exibir metricas de
uso de tokens, custos e recomendacoes de modelo.

### Instrucoes para o Agente:

1. **Leia** a arquitetura, user stories e contratos de API.
2. **Configure** o projeto Next.js:
   - Next.js App Router com TypeScript.
   - Tailwind CSS para estilizacao.
   - Componentes UI: shadcn/ui ou similar.
   - Biblioteca de graficos: Recharts ou Tremor.
   - State management: React Query (TanStack Query) para server state.
   - Autenticacao: NextAuth.js com JWT.

3. **Implemente** o Design System:
   - Theme TokenOps (cores, tipografia, espacamento).
   - Componentes base: Button, Card, Input, Select, Table, Badge, Tooltip.
   - Componentes de graficos reutilizaveis: LineChart, BarChart, PieChart, AreaChart.
   - Layout: Sidebar navigation, Header, Content area.
   - Modo escuro (dark mode).

4. **Implemente** as paginas do Dashboard:

   **a) Overview (Home):**
   - Cards com metricas principais: Total Tokens, Total Cost, Total Requests, Avg Cost/Request.
   - Grafico de uso de tokens por dia (ultimos 30 dias).
   - Grafico de custo por provider/modelo (pie chart).
   - Top 5 modelos mais usados.
   - Alertas recentes (se houver).

   **b) Usage Explorer:**
   - Grafico de tokens consumidos por periodo (line chart).
   - Breakdown por modelo, provider, time, projeto.
   - Tabela detalhada de requests com paginacao.
   - Filtros: periodo, modelo, provider, time, projeto.
   - Exportacao CSV/JSON.

   **c) Cost Explorer (MVP simplificado):**
   - Grafico de custo por periodo (area chart).
   - Breakdown por modelo, provider, time.
   - Comparacao de custo entre modelos.
   - Tabela de pricing por modelo/provider.

   **d) Model Recommendation:**
   - Interface para descrever task e constraints.
   - Resultado: ranking de modelos recomendados com custo estimado.
   - Comparacao lado a lado de modelos.

   **e) Token Estimator:**
   - Textarea para input de prompt.
   - Selecao de modelo.
   - Resultado: tokens estimados + custo estimado.
   - Comparacao de custo entre modelos para o mesmo prompt.

   **f) Settings:**
   - Gestao de API keys (criar, revogar, listar).
   - Gestao de projetos e times.
   - Configuracoes de notificacao.
   - Perfil do usuario.

5. **Integre** com as APIs:
   - Camada de servico HTTP com axios/fetch.
   - React Query para cache e refetch automatico.
   - Tratamento de erros de rede (toast notifications).
   - Loading states e skeleton screens.
   - Autenticacao com JWT (interceptor).

6. **Escreva** testes de componente:
   - Testes de renderizacao para cada pagina.
   - Testes de interacao (filtros, exportacao, navegacao).
   - Testes de integracao com API (mocked com MSW).
   - Testes de acessibilidade.

7. **Garanta** qualidade visual:
   - Responsividade (mobile, tablet, desktop).
   - Acessibilidade (WCAG 2.1 AA).
   - Performance (Core Web Vitals).
   - Dark mode funcional.

### Ferramentas Recomendadas:

- **Devin** para implementacao autonoma de paginas.
- **GitHub Copilot** para autocompletar React/Next.js.
- **v0.dev** para prototipacao rapida de componentes UI.

### Regras:

- Componentes devem ser acessiveis (aria labels, keyboard navigation).
- Cada componente deve ter pelo menos 1 teste.
- Nao duplicar logica que pertence ao backend.
- Graficos devem ser responsivos e suportar diferentes resolucoes de dados.
- Internacionalizacao preparada (mesmo que com 1 idioma — pt-BR).
- Todos os dados monetarios devem exibir moeda (USD/BRL).

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Contratos de API, estrutura frontend |
| User Stories | `output/requirements/user-stories.md` | Fluxos de usuario |
| Sprint Backlog | `output/planning/sprint-backlog.md` | Tarefas de frontend |
| Backend Code | `output/implementation/backend/` | APIs implementadas para integracao |
| Test Strategy | `output/planning/test-strategy.md` | Metas de cobertura |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Frontend Code | `output/implementation/frontend/` | Codigo fonte Next.js completo |
| Component Tests | `output/implementation/frontend/tests/` | Testes de componente |
| Frontend Report | `output/implementation/frontend/implementation-report.md` | Relatorio de implementacao |

## Execution Mode

- **Modo:** Subagent
- **Agente:** `dev-frontend`
- **Skills:** `implement-ui`, `integrate-api`, `write-component-tests`
- **Timeout:** 60 minutos
- **Retries:** 2

## Quality Gate

Antes de avancar para o Step 11, verifique:

- [ ] Todas as paginas do Dashboard implementadas (Overview, Usage, Cost, Recommendation, Estimator, Settings)
- [ ] Integracao com todas as APIs do backend funcional
- [ ] Graficos de tokens e custos renderizando corretamente
- [ ] Filtros por periodo, modelo, provider, time funcionais
- [ ] Exportacao CSV/JSON funcional
- [ ] Token Estimator funcional com comparacao de modelos
- [ ] Model Recommendation funcional
- [ ] Gestao de API keys funcional
- [ ] Testes de componente passando
- [ ] Cobertura de testes dentro da meta
- [ ] Acessibilidade validada (WCAG 2.1 AA)
- [ ] Responsividade testada (mobile, tablet, desktop)
- [ ] Dark mode funcional
- [ ] Performance aceitavel (Core Web Vitals)
- [ ] Codigo segue padroes Next.js/React da arquitetura
