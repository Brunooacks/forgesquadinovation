---
step: "10"
name: "Implementacao Frontend"
type: agent
agent: dev-frontend
tasks:
  - implement-ui
  - integrate-api
  - write-component-tests
depends_on: step-09
phase: implementation
---

# Step 10: Dev Frontend — Implementacao Frontend

## Para o Pipeline Runner

Acione o agente `dev-frontend` com as tasks `implement-ui`, `integrate-api` e
`write-component-tests`. O desenvolvedor frontend deve implementar a interface
do usuario, integrar com as APIs do backend e escrever testes de componente.

### Instrucoes para o Agente:

1. **Leia** a arquitetura, user stories e contratos de API.
2. **Configure** o projeto:
   - Estrutura de diretorio conforme arquitetura.
   - Framework e dependencias.
   - Configuracao de build e bundler.
   - Design system ou biblioteca de componentes.
3. **Implemente** a interface:
   - Componentes reutilizaveis (atoms, molecules, organisms).
   - Paginas e rotas conforme user stories.
   - Formularios com validacao client-side.
   - Feedback visual (loading, erro, sucesso).
   - Responsividade (mobile-first).
4. **Integre** com as APIs:
   - Camada de servico HTTP (client API).
   - Gerenciamento de estado (global e local).
   - Tratamento de erros de rede.
   - Autenticacao (token management).
   - Cache e otimizacao de requests.
5. **Escreva** testes de componente:
   - Testes de renderizacao para cada componente.
   - Testes de interacao (click, input, submit).
   - Testes de integracao com API (mocked).
   - Testes de acessibilidade.
6. **Garanta** qualidade visual:
   - Acessibilidade (WCAG 2.1 AA minimo).
   - Performance (Core Web Vitals).
   - Cross-browser compatibility.

### Ferramentas Recomendadas:

- **Devin** para implementacao autonoma de features.
- **GitHub Copilot** para autocompletar e sugestoes.
- **v0.dev** para prototipacao rapida de UI.

### Regras:

- Componentes devem ser acessiveis (aria labels, keyboard navigation).
- Cada componente deve ter pelo menos 1 teste.
- Nao duplicar logica que pertence ao backend.
- Seguir design system definido na arquitetura.
- Internacionalizacao preparada (mesmo que com 1 idioma).

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
| Frontend Code | `output/implementation/frontend/` | Codigo fonte do frontend |
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

- [ ] Todas as paginas e fluxos implementados
- [ ] Integracao com APIs do backend funcional
- [ ] Testes de componente passando
- [ ] Cobertura de testes dentro da meta
- [ ] Acessibilidade validada (WCAG 2.1 AA)
- [ ] Responsividade testada (mobile, tablet, desktop)
- [ ] Tratamento de erros de rede implementado
- [ ] Performance aceitavel (Core Web Vitals)
- [ ] Codigo segue padroes da arquitetura
