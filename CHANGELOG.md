# ForgeSquad — Changelog

Todas as mudanças notáveis do ForgeSquad são documentadas neste arquivo.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

---

## [2.0.0] — 2026-03-22 — "Prometheus"

### Adicionado
- **SRE Engineer** — novo agente (monitoring, SLOs/SLIs, incident response, chaos engineering, observabilidade)
- **DevOps Engineer** — novo agente (CI/CD, IaC, GitOps, deployment strategies, container orchestration)
- **Capabilities model** — abstração de ferramentas (7 capacidades, 7+ providers)
- **Providers suportados:** Claude Code, Devin, Cursor, Windsurf, Copilot, Codex, Kiro
- **Embedded Intelligence** — Software Architecture (Fowler/DDD/SOLID) e Cryptography auto-injetados nos agentes relevantes
- **Ralph Loop** — modo de execução padrão para desenvolvedores (iteração autônoma com quality gates)
- **Metodologias:** Waterfall, Scrum, Kanban selecionáveis por squad
- **Dev Journey Engine** — geração automática de roadmap e release plan
- **Production Output Standard** — padrão obrigatório para outputs production-ready
- **Governance layer** — policies, metrics rollup, audit trail automático
- **Scale config** — suporte a 375+ squads simultâneos (3000+ devs)

### Alterado
- Catálogo de agentes: 9 → 11 agentes
- Skills substituídas por capabilities (desacoplamento de vendors)
- 3 modos de execução: inline, subagent, ralph-loop (antes: inline, subagent)
- `config.yaml` reestruturado em 3 camadas (Governance, Squad, Execution)
- Landing page redesenhada com storytelling enterprise

### Removido
- Referências diretas a ferramentas específicas nos agentes (movido para capabilities)
- Skills de Software Architect e Cryptography (movido para embedded intelligence)

---

## [1.1.0] — 2026-03-17

### Adicionado
- **Novo agente: Finance Advisor** — Consultor de Negócios do Setor Financeiro
  - Knowledge base completa: Bacen (CMN 4.893, BCB 80, BCB 199, Circular 3.978), BIAN v12, Basileia III/IV, Open Finance Brasil, Pix, PCI DSS v4.0, LGPD, SOX
  - Vocabulário de domínio: 25+ termos financeiros (SFN, SPB, SPI, DICT, PLD/FT, KYC, AML, FAPI, DREX, BaaS, SCD, SEP)
  - Checklist de validação com 10 pontos de compliance
  - Formato padronizado de parecer (Aprovado / Aprovado com Ressalvas / Reprovado)
- **3 novos steps no pipeline:**
  - `step-03b` — Parecer de Negócios (após aprovação de requisitos)
  - `step-05b` — Validação Regulatória da Arquitetura (após revisão arquitetural)
  - `step-17b` — Sign-off Regulatório Final (antes do deploy em produção)
- **Veto Conditions financeiras** — Finance Advisor pode bloquear o pipeline por non-compliance
- **Dashboard atualizado** — Grid 3x3 com 9 agentes, Finance Advisor com avatar teal e tools Bacen/BIAN
- **Simulação expandida** — 23 steps (era 20), incluindo participação do Finance Advisor
- **Documento de Arquitetura para Patente** — `docs/FORGESQUAD-ARCHITECTURE-PATENT.md` (1.209 linhas, 17 reivindicações)
- **Guias de Implementação** — Step-by-step para Microsoft (Azure/Copilot Studio) e AWS (Bedrock/Step Functions)
- **Sistema de versionamento** — CHANGELOG.md, versão em config.yaml, script de release

### Alterado
- `squad.yaml` — Adicionado finance-advisor como 9º agente
- `squad-party.csv` — Nova linha para Finance Advisor
- `pipeline.yaml` — 23 steps (3 novos), novos artefatos de output (6 arquivos adicionais)
- `config.yaml` — Adicionado `finance_advisor: powerful` nos model tiers
- `dashboard.html` — Grid de 4x2 para 3x3, novo agente e steps de simulação

---

## [1.0.0] — 2026-03-16 — "Genesis"

### Adicionado
- **Framework core** — `_forgesquad/` com config, core agents, pipeline runner, skills engine
- **8 agentes base:** Architect, Tech Lead, Business Analyst, Dev Backend, Dev Frontend, QA Engineer, Tech Writer, Project Manager
- **Pipeline de 9 fases / 20 steps** — Requisitos → Arquitetura → Planejamento → Implementação → Qualidade → Code Review → Documentação → Deploy → Sustentação
- **7 checkpoints human-in-the-loop** — Decisões críticas requerem aprovação humana
- **Skills Engine** — Integração plugável com Devin, Copilot, StackSpot, Kiro, Jira Sync, SonarQube
- **Best Practices Engine** — Injeção contextual de boas práticas por tipo de step
- **State Machine** — `state.json` para monitoramento em tempo real
- **Dashboard interativo** — Tema spaceship bridge, robôs SVG procedurais, modo Demo/Live
- **Landing page** — `docs/index.html` com detalhes do framework
- **Squad template** — `forge-engineering` como squad de referência
- **Memória persistente** — Company context, tech stack, preferences
