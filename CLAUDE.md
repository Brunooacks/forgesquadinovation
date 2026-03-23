# ForgeSquad v2.0 — Project Instructions

This project uses **ForgeSquad v2.0**, an enterprise-scale multi-agent orchestration framework for Software Engineering squads with embedded intelligence and capability-driven architecture.

## Quick Start

Type `/forgesquad` to open the main menu, or use any of these commands:
- `/forgesquad create` — Create a new engineering squad
- `/forgesquad run <name>` — Run a squad pipeline
- `/forgesquad report <name>` — Generate status report for project manager
- `/forgesquad help` — See all commands

## Directory Structure

- `_forgesquad/` — ForgeSquad core files (do not modify manually)
- `_forgesquad/_memory/` — Persistent memory (company context, tech stack, preferences)
- `_forgesquad/core/` — Core agents, pipeline runners, and engine definitions
- `_forgesquad/core/intelligence/` — Embedded intelligence (auto-injected, invisible to agents)
- `_forgesquad/core/templates/` — Production scaffolding templates
- `_forgesquad/methodologies/` — Methodology definitions (Waterfall, Scrum, Kanban)
- `skills/` — Provider integrations (Devin, Copilot, StackSpot, Kiro, etc.)
- `squads/` — User-created engineering squads
- `squads/{name}/agents/` — Squad-specific agent definitions
- `squads/{name}/pipeline/` — Pipeline definition and step files
- `squads/{name}/output/` — Generated artifacts (docs, code, reports)
- `squads/{name}/reports/` — Project manager status reports

## How It Works

1. The `/forgesquad` command is the entry point for all interactions
2. The **Architect** agent designs squads and oversees the entire engineering journey
3. Agents declare **capabilities** they need; the engine resolves them to providers via `config.yaml`
4. **Embedded intelligence** is auto-injected into agent contexts — invisible to the agent, always active
5. The **Pipeline Runner** executes squads automatically, step by step
6. Agents communicate via persona switching (inline) or subagents (background)
7. Checkpoints pause execution for user input/approval (architectural decisions, PR reviews, go/no-go)
8. The **Project Manager** agent generates status reports at any checkpoint
9. The **Ralph Loop** is the default development cycle for all dev agents (Backend, Frontend, SRE, DevOps)

## Squad Roles (11 Agents)

| Role | Responsibility |
|------|---------------|
| Architect | System design, architectural decisions, tech stack governance, quality gates |
| Tech Lead | Technical coordination, code standards, sprint planning, PR reviews |
| Business Analyst | Requirements engineering, user stories, acceptance criteria, reverse engineering |
| Developer (Backend) | Backend implementation, APIs, databases, integrations |
| Developer (Frontend) | Frontend implementation, UI/UX, responsive design |
| SRE | Site reliability, observability, SLOs/SLIs, incident response, chaos engineering |
| DevOps | CI/CD pipelines, infrastructure automation, deployment strategies, container orchestration |
| QA Engineer | Test strategy, automation, regression, performance testing |
| Tech Writer | Technical documentation, API docs, runbooks, ADRs |
| Cryptography | Security architecture, encryption, key management, compliance |
| Project Manager | Status reports, progress tracking, risk management, stakeholder updates |

## Capabilities Model

Agents declare capabilities rather than referencing specific tools. The engine resolves capabilities to providers:

- **Native capabilities** — built-in AI reasoning, no provider needed
- **Provider integrations** — external tools mapped via `config.yaml` (Devin, Copilot, StackSpot, Kiro, etc.)
- **Embedded intelligence** — auto-injected context that enhances agent behavior invisibly

## Methodology Support

Squads can operate under different methodologies defined in `_forgesquad/methodologies/`:
- **Waterfall** — sequential phases with formal gates
- **Scrum** — iterative sprints with ceremonies
- **Kanban** — continuous flow with WIP limits

## Rules

- Always use `/forgesquad` commands to interact with the system
- Do not manually edit files in `_forgesquad/core/` unless you know what you're doing
- Squad YAML files can be edited manually if needed, but prefer using `/forgesquad edit`
- Company context in `_forgesquad/_memory/company.md` is loaded for every squad run
- The Architect participates in EVERY phase — from requirements to production
- Reports are generated automatically at each checkpoint for the Project Manager
- Embedded intelligence files are auto-injected and should not be referenced directly by agents
- The Ralph Loop is the default development cycle for dev agents — do not bypass it unless explicitly overridden
