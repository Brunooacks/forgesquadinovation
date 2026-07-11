# Fase 6 — Web Dashboard

## Agente Responsavel
**Dev Ana Frontend** (subagent)

## Objetivo
Implementar o painel web de gestao e consolidacao de prompts.

## Tasks

### 1. Setup do Projeto
- Inicializar Next.js 14+ com App Router
- Configurar Tailwind CSS
- Instalar shadcn/ui components
- Configurar Vitest + Testing Library

### 2. Layout Base
- Sidebar com navegacao (Home, Search, Categories, Dashboard, Generator)
- Header com busca rapida e user menu
- Content area responsiva
- Dark mode support

### 3. Pagina de Busca
- Input de busca com debounce
- Filtros laterais (categoria, tags, complexidade, target)
- Cards de resultado com preview
- Paginacao

### 4. Pagina de Detalhe do Prompt
- Render Markdown completo
- Botao copiar para clipboard
- Botao favoritar
- Metadados (autor, data, versao, tags)
- Prompts relacionados

### 5. CRUD de Prompts
- Formulario de criacao com editor Markdown
- Preview ao vivo (split pane)
- Edicao de frontmatter (formulario estruturado)
- Confirmacao de exclusao

### 6. Dashboard de Metricas
- Top 10 prompts mais usados (bar chart)
- Uso por categoria (pie chart)
- Tendencia de uso (line chart — ultimos 30 dias)
- Total de prompts, usuarios, geracoes

### 7. Pagina do Robo Gerador
- Wizard em 3 passos:
  1. Selecionar tipo (agente, script, template)
  2. Preencher contexto (projeto, tech stack, objetivo)
  3. Preview e download
- Loading state com streaming de resposta LLM
- Botao download (.md ou .yaml)

## Output
- Codigo fonte em `output/code/web/`
- Testes em `output/code/web/__tests__/`
