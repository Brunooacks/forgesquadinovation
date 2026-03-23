# ForgeSquad — Setup no Visual Studio Code

Guia completo para configurar e usar o ForgeSquad no VS Code.

## Pre-requisitos

- Visual Studio Code 1.85+
- Uma extensao de AI instalada (pelo menos uma)

## Passo 1: Instalar Extensao de AI

Escolha UMA (ou mais) das opcoes abaixo:

### Opcao A: GitHub Copilot (Recomendado)
```
1. Abra VS Code
2. Ctrl+Shift+X (Extensions)
3. Busque "GitHub Copilot"
4. Instale "GitHub Copilot" + "GitHub Copilot Chat"
5. Faca login com sua conta GitHub
```
O ForgeSquad sera lido automaticamente via `COPILOT.md`.

### Opcao B: Continue.dev (Claude ou GPT)
```
1. Ctrl+Shift+X → Busque "Continue"
2. Instale "Continue - Codestral, Claude, and more"
3. Configure seu provider (Anthropic, OpenAI, ou local)
```
O ForgeSquad sera lido via `AGENTS.md`.

### Opcao C: Cline (Claude)
```
1. Ctrl+Shift+X → Busque "Cline"
2. Instale "Cline" (antigo Claude Dev)
3. Configure sua API key da Anthropic
```
O ForgeSquad sera lido via `CLAUDE.md`.

### Opcao D: Amazon Q Developer
```
1. Ctrl+Shift+X → Busque "Amazon Q"
2. Instale "Amazon Q Developer"
3. Faca login com sua conta AWS
```
O ForgeSquad sera lido via `AGENTS.md`.

## Passo 2: Abrir o Projeto

```bash
# Clone o framework (primeira vez)
git clone https://github.com/Brunooacks/ForgeSquadAI-Augmented-byAurora.git
cd ForgeSquadAI-Augmented-byAurora

# Abra no VS Code
code .
```

Quando abrir, o VS Code vai sugerir instalar as extensoes recomendadas.
Clique "Install All" para aceitar.

## Passo 3: Usar o ForgeSquad

### Com GitHub Copilot Chat
```
1. Abra o Copilot Chat (Ctrl+Shift+I)
2. Digite: /forgesquad
3. O Copilot vai ler COPILOT.md e apresentar o menu
4. Siga as instrucoes do framework
```

### Com Continue.dev
```
1. Abra o Continue sidebar (Ctrl+L)
2. Digite: /forgesquad create "Meu projeto com React + Node.js"
3. O Continue vai ler AGENTS.md e iniciar o Architect
4. Siga as instrucoes do framework
```

### Com Cline
```
1. Abra o Cline sidebar
2. Digite: /forgesquad
3. O Cline vai ler CLAUDE.md e apresentar o menu
4. Siga as instrucoes do framework
```

### Com Amazon Q
```
1. Abra o Amazon Q Chat
2. Digite: Leia o arquivo AGENTS.md e siga as instrucoes do ForgeSquad
3. O Q vai carregar o framework
4. Siga as instrucoes
```

## Passo 4: Criar um Novo Projeto

Em QUALQUER extensao de AI, o fluxo e o mesmo:

```
Voce: /forgesquad create "E-commerce com React + Node.js + PostgreSQL"

ForgeSquad:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Arquiteto de Solucoes — Discovery
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Pergunta 1/5: Qual e o tipo do projeto?
  1. Greenfield (novo)
  2. Brownfield (modernizacao)
  3. Sustaining (manutencao)

Voce: 1

ForgeSquad:
  Pergunta 2/5: Qual metodologia de gestao?
  1. Default (Linear)
  2. Waterfall
  3. Scrum
  4. Kanban

Voce: 3

  ... (continua ate configurar tudo)

ForgeSquad:
  Squad montado: 11 agentes, Scrum, 5 sprints
  Aprovar? [S]im / [N]ao

Voce: S

  Arquivos gerados em: ~/Documents/meu-ecommerce/.forgesquad/
```

## Passo 5: Executar o Pipeline

```
Voce: /forgesquad run meu-ecommerce

ForgeSquad:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Running squad: meu-ecommerce
  Pipeline: 24 steps
  Methodology: Scrum
  Agents: 11
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Step 1/24: Checkpoint — Briefing do Projeto
  [AGUARDANDO SUA APROVACAO]
  ...
```

O pipeline vai pausar em CADA checkpoint pedindo sua aprovacao.
Todos os artefatos sao gerados automaticamente em `.forgesquad/runs/`.

## Estrutura de Arquivos Gerada

```
meu-ecommerce/
├── .forgesquad/                    # ForgeSquad metadata
│   ├── state.json                  # Estado atual do pipeline
│   ├── squad.yaml                  # Configuracao do squad
│   ├── pipeline/                   # Pipeline definition
│   │   ├── pipeline.yaml
│   │   └── steps/
│   ├── agents/                     # Agent personas
│   ├── runs/                       # Execucoes (audit trail)
│   │   └── 2026-03-23-140000/
│   │       ├── audit-trail.json
│   │       ├── step-01-briefing.md
│   │       ├── step-02-requirements.md
│   │       ├── checkpoint-step-03.md
│   │       └── final-report.md
│   └── backups/                    # Snapshots automaticos
├── src/                            # Codigo fonte (gerado)
├── tests/                          # Testes (gerado)
├── docs/                           # Documentacao (gerado)
├── docker/                         # Docker (gerado)
├── Makefile                        # Comandos padronizados
└── README.md                       # Getting started
```

## Atalhos Uteis no VS Code

| Atalho | Acao |
|---|---|
| `Ctrl+Shift+I` | Abrir Copilot Chat |
| `Ctrl+L` | Abrir Continue |
| `Ctrl+Shift+P` → "ForgeSquad" | Buscar comandos |
| `Ctrl+`` ` | Abrir terminal integrado |
| `Ctrl+Shift+E` | Explorer (ver arquivos) |

## Troubleshooting

**"O AI nao reconhece /forgesquad"**
→ Verifique se o arquivo de instrucoes existe (COPILOT.md, AGENTS.md, CLAUDE.md).
Tente dizer ao AI: "Leia o arquivo AGENTS.md e siga as instrucoes".

**"O AI pula checkpoints"**
→ Diga: "PARE. Voce deve seguir o runner.executable.md. Nao pule checkpoints."
O runner tem instrucoes explicitas para parar. Reforce se necessario.

**"Nao gera artefatos"**
→ Verifique se o diretorio .forgesquad/runs/ existe.
Diga ao AI: "Gere todos os artefatos conforme o runner.executable.md".

**"Qual extensao de AI e melhor?"**
→ Para ForgeSquad, recomendamos Copilot Chat ou Continue.dev com Claude.
Ambos seguem bem instrucoes longas e estruturadas.

## Compatibilidade

| IDE/Editor | Extensao | Arquivo | Status |
|---|---|---|---|
| VS Code | GitHub Copilot | COPILOT.md | Pronto |
| VS Code | Continue.dev | AGENTS.md | Pronto |
| VS Code | Cline | CLAUDE.md | Pronto |
| VS Code | Amazon Q | AGENTS.md | Pronto |
| Cursor | Nativo | .cursorrules | Pronto |
| Claude Code | Nativo | CLAUDE.md | Pronto |
| Windsurf | Nativo | AGENTS.md | Pronto |
| Codex CLI | Nativo | AGENTS.md | Pronto |

---

*ForgeSquad v2.0 — Enterprise Multi-Agent Framework*
*Funciona em qualquer IDE. Qualquer AI. Qualquer projeto.*
