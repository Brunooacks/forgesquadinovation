# ForgeSquad

Crie squads de engenharia de software com agentes de IA que trabalham juntos — direto da sua IDE.

ForgeSquad é um framework de orquestração multi-agente focado em **engenharia de software**. Descreva o projeto que você precisa construir, e o ForgeSquad cria uma equipe de agentes especializados que cobrem todo o ciclo de vida — da elicitação de requisitos até a publicação em produção e sustentação.

## O que é um Squad?

Um squad é uma equipe de agentes de IA que colaboram em um projeto de software. Cada agente tem um papel específico. Eles executam em pipeline — você só intervém nos checkpoints de decisão.

### Composição do Squad

| Agente | Papel | Ferramentas |
|--------|-------|-------------|
| 🏗️ **Arquiteto** | Design de sistema, decisões técnicas, ADRs, revisão arquitetural | Web Search |
| 📋 **Tech Lead** | Coordenação técnica, code review, sprint planning, padrões de código | Copilot, Devin |
| 📊 **Analista de Negócios** | Requisitos, user stories, critérios de aceite, engenharia reversa | Kiro |
| 🔧 **Dev Backend** | APIs, serviços, banco de dados, integrações, migrations | Devin, Copilot, StackSpot |
| 🎨 **Dev Frontend** | UI/UX, componentes, responsividade, acessibilidade | Devin, Copilot |
| 🔍 **QA Engineer** | Estratégia de testes, automação, regressão, performance | Devin, Copilot |
| 📝 **Tech Writer** | API docs, runbooks, ADRs, release notes, user guides | Web Search |
| 📈 **Gerente de Projeto** | Status reports, métricas, riscos, acompanhamento | Jira Sync |
| 🏦 **Finance Advisor** | Compliance Bacen/BIAN, Basel III/IV, Open Finance, Pix, PCI DSS, LGPD | Web Search, Bacen, BIAN |

### O Arquiteto em Todas as Fases

O **Arquiteto** é o guardião da qualidade arquitetural e participa de **todas** as fases do ciclo de vida:

- **Requisitos**: Valida que requisitos não-funcionais estão capturados
- **Arquitetura**: Projeta o sistema e documenta decisões (ADRs)
- **Planejamento**: Valida que tasks técnicas são viáveis
- **Implementação**: Disponível para decisões técnicas estruturais
- **Qualidade**: Define fitness functions e quality gates
- **Code Review**: Revisa código para conformidade arquitetural
- **Deploy**: Valida infraestrutura e estratégia de deployment
- **Sustentação**: Orienta decisões de manutenção e evolução

## Pipeline de Engenharia

O pipeline cobre 10 fases com 24 steps e 9 checkpoints de decisão:

```
📊 Estimativa ──→ 📋 Requisitos ──→ 🏗️ Arquitetura ──→ 📅 Planejamento ──→ ⚙️ Implementação
      │                  │                  │                    │                    │
  [checkpoint]      [checkpoint]      [checkpoint]         [checkpoint]         [checkpoint]
      │                  │                  │                    │                    │
      ▼                  ▼                  ▼                    ▼                    ▼
🔍 Qualidade ──→ 👀 Code Review ──→ 📝 Documentação ──→ 🏦 Compliance ──→ 🚀 Deploy
      │                  │                                      │               │
      │             [on_reject]                            [sign-off]      [Go/No-Go]
      │              ↩ volta                                                    │
      ▼                                                                         ▼
                                                                          🔧 Sustentação
                                                                               │
                                                                          [Encerramento]
```

### Fases Detalhadas

1. **Estimativa** — Finance Advisor estima custos, effort e compliance regulatório
2. **Requisitos** — BA elicita requisitos, escreve user stories com Kiro, Arquiteto valida
3. **Arquitetura** — Arquiteto projeta sistema, cria ADRs, apresenta trade-offs para aprovação
4. **Planejamento** — Tech Lead quebra em sprint tasks, QA define estratégia de testes
5. **Implementação** — Devs implementam com Devin/Copilot/StackSpot, Arquiteto suporta
6. **Qualidade** — QA executa testes automatizados e de performance
7. **Code Review** — Tech Lead + Arquiteto revisam código (pode rejeitar → volta para implementação)
8. **Documentação** — Tech Writer gera API docs, runbook, release notes
9. **Deploy** — Go/No-Go checkpoint, deploy com StackSpot, validação em produção
10. **Sustentação** — PM gera relatório final, handover para time de sustentação

## Ferramentas Integradas

| Ferramenta | Categoria | Uso |
|------------|-----------|-----|
| **Devin** | Development | Coding autônomo, bug fixes, implementação de features |
| **GitHub Copilot** | Development | Pair programming, sugestões inline, code generation |
| **StackSpot** | Infrastructure | Templates de IaC, provisioning de ambientes cloud |
| **Kiro** | Requirements | Geração de specs, user stories, task breakdown |
| **Jira Sync** | PM | Sincronização de status, métricas de velocity |
| **SonarQube** | Quality | Análise estática, quality gates, security scanning |

## Instalação

**Pré-requisito:** IDE com suporte a agentes de IA (Claude Code, Cursor, VS Code + Copilot)

1. Clone ou copie este repositório para seu projeto
2. Abra na IDE
3. Execute `/forgesquad` para iniciar o onboarding

## Criando seu Squad

```
/forgesquad create "E-commerce platform com React + Node.js + PostgreSQL"
```

O **Arquiteto** faz algumas perguntas sobre o projeto, projeta o squad e configura tudo automaticamente. Você aprova o design antes de qualquer execução.

## Executando um Squad

```
/forgesquad run forge-engineering
```

O squad executa automaticamente, pausando apenas nos checkpoints onde sua decisão é necessária.

## Reports do Gerente de Projeto

```
/forgesquad report forge-engineering
```

Gera um relatório de status com:
- Progresso por fase (% concluído)
- Artefatos gerados
- Decisões tomadas nos checkpoints
- Métricas de qualidade (cobertura, SonarQube)
- Riscos e bloqueios
- Projeção de timeline baseada em velocity

## Engenharia Reversa

```
/forgesquad analyze ./legacy-system
```

Analisa um codebase existente para:
- Identificar tech stack e dependências
- Mapear arquitetura e padrões
- Documentar comportamento atual (AS-IS)
- Propor squad de sustentação ou modernização

## Comandos

| Comando | O que faz |
|---------|-----------|
| `/forgesquad` | Abre o menu principal |
| `/forgesquad help` | Mostra todos os comandos |
| `/forgesquad create` | Cria um novo squad de engenharia |
| `/forgesquad run <name>` | Executa o pipeline de um squad |
| `/forgesquad report <name>` | Gera relatório de status |
| `/forgesquad list` | Lista seus squads |
| `/forgesquad edit <name>` | Modifica um squad |
| `/forgesquad analyze <path>` | Engenharia reversa de codebase |
| `/forgesquad skills` | Gerencia ferramentas integradas |
| `/forgesquad delete <name>` | Remove um squad |

## Estrutura de Diretórios

```
project/
├── CLAUDE.md                          # Instruções do projeto
├── README.md                          # Este arquivo
├── .gitignore
├── _forgesquad/                       # Core do framework
│   ├── config.yaml                    # Configuração de model tiers
│   ├── _memory/                       # Contexto persistente
│   │   ├── company.md                 # Perfil da empresa
│   │   ├── tech-stack.md              # Stack tecnológico
│   │   └── preferences.md            # Preferências do usuário
│   └── core/                          # Engine files
│       ├── architect.agent.yaml       # Definição do Arquiteto core
│       ├── runner.pipeline.md         # Pipeline Runner
│       ├── skills.engine.md           # Skills Engine
│       └── best-practices/            # Boas práticas por domínio
│           ├── _catalog.yaml
│           ├── api-design.md
│           ├── code-review.md
│           ├── testing.md
│           ├── documentation.md
│           ├── requirements.md
│           ├── deployment.md
│           ├── security.md
│           └── observability.md
├── skills/                            # Integrações de ferramentas
│   ├── devin/SKILL.md
│   ├── copilot/SKILL.md
│   ├── stackspot/SKILL.md
│   ├── kiro/SKILL.md
│   ├── jira-sync/SKILL.md
│   └── sonarqube/SKILL.md
├── squads/                            # Squads criados
│   └── forge-engineering/             # Exemplo de squad
│       ├── squad.yaml                 # Definição do squad
│       ├── squad-party.csv            # Agentes e personas
│       ├── _memory/memories.md        # Memória do squad
│       ├── agents/                    # Definições de agentes
│       │   ├── architect.agent.md
│       │   ├── tech-lead.agent.md
│       │   ├── business-analyst.agent.md
│       │   ├── dev-backend.agent.md
│       │   ├── dev-frontend.agent.md
│       │   ├── qa-engineer.agent.md
│       │   ├── tech-writer.agent.md
│       │   └── project-manager.agent.md
│       ├── pipeline/                  # Pipeline de execução
│       │   ├── pipeline.yaml          # Definição (20 steps, 9 fases)
│       │   ├── steps/                 # Arquivos de cada step
│       │   │   ├── step-01-project-briefing.md
│       │   │   ├── step-02-requirements.md
│       │   │   ├── ...
│       │   │   └── step-20-closure.md
│       │   └── data/                  # Padrões e checklists
│       │       ├── coding-standards.md
│       │       ├── architecture-guidelines.md
│       │       ├── testing-strategy.md
│       │       ├── definition-of-done.md
│       │       ├── definition-of-ready.md
│       │       └── deployment-checklist.md
│       ├── output/                    # Artefatos gerados (por run)
│       └── reports/                   # Relatórios do PM (por run)
└── .claude/
    └── skills/
        └── forgesquad/
            └── SKILL.md               # Entry point do framework
```

## Licença

MIT — use como quiser.
