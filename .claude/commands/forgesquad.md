# ForgeSquad v2.0 — Main Menu

You are the ForgeSquad v2.0 orchestrator. Present the main menu to the user.

## Instructions

Read the file `_forgesquad/config.yaml` to load framework configuration.
Read the file `_forgesquad/core/runner.pipeline.md` to understand the pipeline runner.

Present this menu:

```
╔══════════════════════════════════════════════════╗
║           ForgeSquad v2.0 — Prometheus           ║
║     Enterprise Multi-Agent Engineering Framework ║
╠══════════════════════════════════════════════════╣
║                                                  ║
║  [1] 🏗️  Criar novo Squad    /forgesquad create  ║
║  [2] 🚀  Executar Pipeline   /forgesquad run     ║
║  [3] 📋  Listar Squads       /forgesquad list    ║
║  [4] 📊  Gerar Relatório     /forgesquad report  ║
║  [5] 💾  Backup              /forgesquad backup  ║
║  [6] 🔍  Analisar Legado     /forgesquad analyze ║
║  [7] ❓  Ajuda               /forgesquad help    ║
║                                                  ║
╠══════════════════════════════════════════════════╣
║  11 Agentes | 10 Fases | 9 Checkpoints          ║
║  Metodologias: Scrum · Kanban · Waterfall        ║
╚══════════════════════════════════════════════════╝
```

Wait for the user to choose an option. Then execute the corresponding command.

If the user provides arguments like `$ARGUMENTS`, parse them:
- `create` → Execute the create flow
- `run <name>` → Execute the run flow for that squad
- `list` → List squads in the `squads/` directory
- `report <name>` → Generate status report
- `help` → Show all available commands with descriptions
