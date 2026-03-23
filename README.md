# ForgeSquad v2.0 — "Prometheus"

Crie squads de engenharia de software com agentes de IA que trabalham juntos — direto da sua IDE. Escala para **3000+ desenvolvedores**.

ForgeSquad é um framework de orquestração multi-agente focado em **engenharia de software enterprise**. Descreva o projeto que você precisa construir, e o ForgeSquad cria uma equipe de **11 agentes especializados** que cobrem todo o ciclo de vida — da elicitação de requisitos até a publicação em produção e sustentação. Suporta **375+ squads simultâneos** com governance centralizada.

## O que é um Squad?

Um squad é uma equipe de agentes de IA que colaboram em um projeto de software. Cada agente tem um papel específico. Eles executam em pipeline — você só intervém nos checkpoints de decisão.

### Composição do Squad

| Agente | Papel | Capabilities |
|--------|-------|-------------|
| 🏗️ **Arquiteto** | Design de sistema, decisões técnicas, ADRs, revisão arquitetural | Research |
| 📋 **Tech Lead** | Coordenação técnica, code review, sprint planning, padrões de código | Code Generation, Code Review |
| 📊 **Analista de Negócios** | Requisitos, user stories, critérios de aceite, engenharia reversa | Spec Generation |
| 🔧 **Dev Backend** | APIs, serviços, banco de dados, integrações, migrations | Code Generation, Infrastructure |
| 🎨 **Dev Frontend** | UI/UX, componentes, responsividade, acessibilidade | Code Generation |
| 🔍 **QA Engineer** | Estratégia de testes, automação, regressão, performance | Code Generation, Test Automation |
| 📝 **Tech Writer** | API docs, runbooks, ADRs, release notes, user guides | Research |
| 📈 **Gerente de Projeto** | Status reports, métricas, riscos, acompanhamento | Project Sync |
| 🏦 **Finance Advisor** | Compliance Bacen/BIAN, Basel III/IV, Open Finance, Pix, PCI DSS, LGPD | Research, Compliance |
| 🛡️ **SRE Engineer** | Monitoring, SLOs/SLIs, incident response, chaos engineering, observabilidade | Infrastructure, Monitoring |
| ⚙️ **DevOps Engineer** | CI/CD, IaC, GitOps, deployment strategies, container orchestration | Infrastructure, Code Generation |

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

## Capabilities Model

O ForgeSquad v2.0 abstrai ferramentas específicas em **capabilities** — capacidades genéricas que podem ser atendidas por diferentes **providers**. Isso desacopla os agentes de vendors específicos.

| Capability | Descrição | Providers |
|------------|-----------|-----------|
| **Code Generation** | Geração e edição de código | Claude Code, Devin, Cursor, Windsurf, Copilot, Codex, Kiro |
| **Code Review** | Revisão de código e sugestões | Claude Code, Copilot, Cursor |
| **Spec Generation** | Geração de specs e user stories | Kiro, Claude Code |
| **Infrastructure** | IaC, provisioning, deploy | Claude Code, Devin, Cursor |
| **Test Automation** | Testes automatizados | Claude Code, Devin, Copilot |
| **Research** | Pesquisa e análise | Web Search, Claude Code |
| **Project Sync** | Sincronização com ferramentas de PM | Jira Sync, Linear |

### Embedded Intelligence

Conhecimento especializado é injetado automaticamente nos agentes que precisam — sem configuração manual:

- **Software Architecture** — Padrões Fowler, DDD, SOLID, Clean Architecture, design patterns aplicados automaticamente pelo Arquiteto e Tech Lead
- **Cryptography** — Boas práticas de criptografia, hashing, key management, TLS/mTLS injetados nos agentes de Backend, SRE e DevOps

## Modos de Execução

O ForgeSquad suporta **3 modos de execução** para steps do pipeline:

| Modo | Descrição | Uso |
|------|-----------|-----|
| **Inline** | Agente executa dentro da sessão principal | Steps de análise, documentação, revisão |
| **Subagent** | Agente executa em background (processo separado) | Steps paralelos, tarefas longas |
| **Ralph Loop** | Iteração autônoma com quality gates automáticos | Steps de implementação (código, testes, IaC) |

O **Ralph Loop** é o modo padrão para steps de desenvolvimento. O agente itera autonomamente — escreve código, roda testes, verifica quality gates — até atingir os critérios de aceite ou esgotar o budget de iterações.

## Metodologias

Cada squad pode ser configurado com a metodologia de gestão mais adequada:

- **Waterfall** — Fases sequenciais com gates formais (ideal para projetos regulatórios)
- **Scrum** — Sprints iterativos com backlog priorizado (ideal para produtos digitais)
- **Kanban** — Fluxo contínuo com WIP limits (ideal para sustentação e bug fixes)

## Pipeline de Engenharia

O pipeline cobre 10 fases com 24 steps e 9 checkpoints de decisão. Steps de implementação usam **Ralph Loop** por padrão:

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
2. **Requisitos** — BA elicita requisitos, escreve user stories (capability: Spec Generation), Arquiteto valida
3. **Arquitetura** — Arquiteto projeta sistema, cria ADRs, apresenta trade-offs para aprovação
4. **Planejamento** — Tech Lead quebra em sprint tasks, QA define estratégia de testes
5. **Implementação** — Devs implementam via **Ralph Loop** (capability: Code Generation), Arquiteto suporta
6. **Qualidade** — QA executa testes automatizados e de performance
7. **Code Review** — Tech Lead + Arquiteto revisam código (pode rejeitar → volta para implementação)
8. **Documentação** — Tech Writer gera API docs, runbook, release notes
9. **Deploy** — Go/No-Go checkpoint, SRE + DevOps validam infraestrutura e deploy (capability: Infrastructure)
10. **Sustentação** — PM gera relatório final, SRE monitora SLOs, handover para time de sustentação

## Providers Suportados

Providers são as ferramentas concretas que implementam as capabilities. O ForgeSquad é agnóstico — você escolhe os providers que já usa.

| Provider | Capabilities |
|----------|-------------|
| **Claude Code** | Code Generation, Code Review, Research, Test Automation, Infrastructure |
| **Devin** | Code Generation, Test Automation, Infrastructure |
| **Cursor** | Code Generation, Code Review, Infrastructure |
| **Windsurf** | Code Generation, Code Review |
| **GitHub Copilot** | Code Generation, Code Review |
| **Codex (OpenAI)** | Code Generation, Test Automation |
| **Kiro** | Spec Generation, Code Generation |
| **SonarQube** | Quality Gates, Security Scanning |
| **Jira / Linear** | Project Sync |

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
- Métricas de qualidade (cobertura, quality gates)
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
| `/forgesquad skills` | Gerencia capabilities e providers |
| `/forgesquad delete <name>` | Remove um squad |

## Estrutura de Diretórios

```
project/
├── CLAUDE.md                          # Instruções do projeto
├── README.md                          # Este arquivo
├── .gitignore
├── _forgesquad/                       # Core do framework
│   ├── config.yaml                    # Configuração (Governance, Squad, Execution)
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
├── skills/                            # Capabilities e embedded intelligence
│   ├── sre/SKILL.md
│   ├── devops/SKILL.md
│   ├── software-architect/SKILL.md
│   ├── cryptography/SKILL.md
│   └── ralph-loop/SKILL.md
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
│       │   ├── project-manager.agent.md
│       │   ├── sre-engineer.agent.md
│       │   └── devops-engineer.agent.md
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
