# Fase 5 — CLI Tool

## Agente Responsavel
**Dev Tiago CLI** (subagent)

## Objetivo
Implementar a ferramenta de linha de comando `promptpilot`.

## Tasks

### 1. Setup do Projeto
- Inicializar projeto Node.js + TypeScript
- Configurar Commander.js
- Configurar tsup para build
- Configurar bin entry no package.json

### 2. Comandos
```bash
promptpilot search <query>     # Busca prompts por texto
promptpilot search -c <cat>    # Busca por categoria
promptpilot search -t <tag>    # Busca por tag

promptpilot list               # Lista todas categorias
promptpilot list <category>    # Lista prompts de uma categoria

promptpilot use <id>           # Exibe prompt e copia para clipboard
promptpilot use <id> --raw     # Output raw (pipe-friendly)

promptpilot generate           # Wizard interativo para gerar agente/script
promptpilot generate -t <tpl>  # Gerar a partir de template especifico
promptpilot generate -c <ctx>  # Gerar com contexto de projeto

promptpilot add                # Wizard interativo para adicionar prompt
promptpilot add -f <file>      # Importar prompt de arquivo

promptpilot config             # Configurar API URL, API key, defaults
```

### 3. Output Formatado
- Tabelas coloridas para listagens (cli-table3 + chalk)
- Spinner para operacoes async (ora)
- Syntax highlighting para preview de prompts
- Progress bar para geracao via LLM

### 4. Configuracao
- `.promptpilotrc` (JSON) no home dir
- Env vars: `PROMPTPILOT_API_URL`, `PROMPTPILOT_API_KEY`
- Comando `promptpilot config` para setup interativo

### 5. Testes
- Testes unitarios para cada comando
- Testes de integracao (execute e assert output)

## Output
- Codigo fonte em `output/code/cli/`
- Testes em `output/code/cli/test/`
