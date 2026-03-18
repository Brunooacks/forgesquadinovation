# ForgeSquad — Changelog

Todas as mudanças notáveis do ForgeSquad são documentadas neste arquivo.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

---

## [1.1.0] — 2026-03-17 — "Ricardo"

### Adicionado
- **Novo agente: FIN Ricardo Regulação** — Consultor de Negócios do Setor Financeiro
  - Knowledge base completa: Bacen (CMN 4.893, BCB 80, BCB 199, Circular 3.978), BIAN v12, Basileia III/IV, Open Finance Brasil, Pix, PCI DSS v4.0, LGPD, SOX
  - Vocabulário de domínio: 25+ termos financeiros (SFN, SPB, SPI, DICT, PLD/FT, KYC, AML, FAPI, DREX, BaaS, SCD, SEP)
  - Checklist de validação com 10 pontos de compliance
  - Formato padronizado de parecer (Aprovado / Aprovado com Ressalvas / Reprovado)
- **3 novos steps no pipeline:**
  - `step-03b` — Parecer de Negócios (após aprovação de requisitos)
  - `step-05b` — Validação Regulatória da Arquitetura (após revisão arquitetural)
  - `step-17b` — Sign-off Regulatório Final (antes do deploy em produção)
- **Veto Conditions financeiras** — Ricardo pode bloquear o pipeline por non-compliance
- **Dashboard atualizado** — Grid 3x3 com 9 agentes, Ricardo com avatar teal e tools Bacen/BIAN
- **Simulação expandida** — 23 steps (era 20), incluindo participação do Finance Advisor
- **Documento de Arquitetura para Patente** — `docs/FORGESQUAD-ARCHITECTURE-PATENT.md` (1.209 linhas, 17 reivindicações)
- **Guias de Implementação** — Step-by-step para Microsoft (Azure/Copilot Studio) e AWS (Bedrock/Step Functions)
- **Sistema de versionamento** — CHANGELOG.md, versão em config.yaml, script de release

### Alterado
- `squad.yaml` — Adicionado finance-advisor como 9º agente
- `squad-party.csv` — Nova linha para FIN Ricardo Regulação
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
