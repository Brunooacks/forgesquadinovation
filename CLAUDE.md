# ForgeSquad — Project Instructions

This project uses **ForgeSquad**, a multi-agent orchestration framework for Software Engineering squads.

## Quick Start

Type `/forgesquad` to open the main menu, or use any of these commands:
- `/forgesquad create` — Create a new engineering squad
- `/forgesquad run <name>` — Run a squad pipeline
- `/forgesquad report <name>` — Generate status report for project manager
- `/forgesquad help` — See all commands

## Directory Structure

- `_forgesquad/` — ForgeSquad core files (do not modify manually)
- `_forgesquad/_memory/` — Persistent memory (company context, tech stack, preferences)
- `_forgesquad/core/` — Core agents and pipeline runners
- `skills/` — Installed skills and tool integrations (Devin, Copilot, StackSpot, Kiro)
- `squads/` — User-created engineering squads
- `squads/{name}/agents/` — Squad-specific agent definitions
- `squads/{name}/pipeline/` — Pipeline definition and step files
- `squads/{name}/output/` — Generated artifacts (docs, code, reports)
- `squads/{name}/reports/` — Project manager status reports

## How It Works

1. The `/forgesquad` skill is the entry point for all interactions
2. The **Architect** agent designs squads and oversees the entire engineering journey
3. The **Pipeline Runner** executes squads automatically, step by step
4. Agents communicate via persona switching (inline) or subagents (background)
5. Checkpoints pause execution for user input/approval (architectural decisions, PR reviews, go/no-go)
6. The **Project Manager** agent generates status reports at any checkpoint

## Squad Roles

| Role | Responsibility |
|------|---------------|
| Architect | System design, architectural decisions, tech stack governance, quality gates |
| Tech Lead | Technical coordination, code standards, sprint planning, PR reviews |
| Business Analyst | Requirements engineering, user stories, acceptance criteria, reverse engineering |
| Developer (Backend) | Backend implementation, APIs, databases, integrations |
| Developer (Frontend) | Frontend implementation, UI/UX, responsive design |
| QA Engineer | Test strategy, automation, regression, performance testing |
| Tech Writer | Technical documentation, API docs, runbooks, ADRs |
| Project Manager | Status reports, progress tracking, risk management, stakeholder updates |

## Tool Integrations

| Tool | Usage |
|------|-------|
| Devin | Autonomous coding tasks, bug fixes, feature implementation |
| GitHub Copilot | Pair programming, code suggestions, inline completions |
| StackSpot | Cloud infrastructure, IaC templates, environment provisioning |
| Kiro | Requirements specs, user stories generation, task breakdown |

## Rules

- Always use `/forgesquad` commands to interact with the system
- Do not manually edit files in `_forgesquad/core/` unless you know what you're doing
- Squad YAML files can be edited manually if needed, but prefer using `/forgesquad edit`
- Company context in `_forgesquad/_memory/company.md` is loaded for every squad run
- The Architect participates in EVERY phase — from requirements to production
- Reports are generated automatically at each checkpoint for the Project Manager
