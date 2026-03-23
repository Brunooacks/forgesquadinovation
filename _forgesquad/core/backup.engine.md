# ForgeSquad Backup Engine

> **SHARED FILE** — applies to ALL IDEs. Do not add IDE-specific logic here.

O Backup Engine garante que todos os projetos gerados pelo ForgeSquad tenham
rotinas de backup automaticas, versionadas e recuperaveis.

## Principio

Todo projeto criado pelo ForgeSquad e codigo + artefatos. O backup deve ser:
- **Automatico** — sem intervencao humana
- **Versionado** — cada backup e um snapshot no tempo
- **Recuperavel** — restaurar qualquer ponto em minutos
- **Distribuido** — nao depender de um unico local

## Estrategia de Backup em 3 Camadas

### Camada 1: Git (Automatico — a cada step)

O Pipeline Runner faz commit automatico apos cada step do pipeline:

```
Apos cada step completar com sucesso:
1. git add -A
2. git commit -m "forgesquad: {step_name} - {agent_name} - {timestamp}"
3. Se remote configurado: git push origin {branch}
```

**Convencao de branches:**
```
main                          # Codigo aprovado e estavel
forgesquad/{run_id}           # Branch por execucao do pipeline
forgesquad/{run_id}/backup    # Snapshots de backup automaticos
```

**Tags automaticas em milestones:**
```
forgesquad/checkpoint/{step_id}   # Cada checkpoint aprovado
forgesquad/review/{step_id}       # Cada code review aprovado
forgesquad/release/{version}      # Cada release do dev-journey
```

### Camada 2: Snapshots Locais (A cada fase/sprint)

Alem do git, o engine cria snapshots compactados localmente:

```
{project_dir}/.forgesquad/backups/
├── 2026-03-23-143000-sprint-1-complete.tar.gz
├── 2026-03-23-160000-sprint-2-complete.tar.gz
├── 2026-03-23-173000-checkpoint-code-review.tar.gz
└── latest -> 2026-03-23-173000-checkpoint-code-review.tar.gz
```

**Quando criar snapshot:**
- Ao final de cada fase (Waterfall) ou sprint (Scrum)
- Apos cada checkpoint aprovado pelo usuario
- Antes de qualquer operacao destrutiva (refactor, migration)
- Manualmente via comando `/forgesquad backup`

**Conteudo do snapshot:**
- Codigo fonte completo
- Artefatos gerados (docs, reports, audit trail)
- state.json (estado do pipeline)
- prd.json e progress.txt (se Ralph Loop ativo)

**Retencao:**
- Ultimos 10 snapshots mantidos automaticamente
- Snapshots de release nunca sao deletados
- Configuravel via `config.yaml`

### Camada 3: Remote Backup (Configuravel)

Para ambientes enterprise, backup remoto opcional:

```yaml
# config.yaml
governance:
  backup:
    enabled: true
    local_snapshots: true
    max_local_snapshots: 10
    remote:
      enabled: false
      # Opcoes:
      # provider: s3
      # bucket: forgesquad-backups-{company}
      # region: us-east-1
      #
      # provider: azure-blob
      # container: forgesquad-backups
      #
      # provider: gcs
      # bucket: forgesquad-backups
```

## Comandos

| Comando | O que faz |
|---|---|
| `/forgesquad backup` | Cria snapshot manual do projeto atual |
| `/forgesquad backup list` | Lista todos os snapshots disponiveis |
| `/forgesquad backup restore {id}` | Restaura um snapshot especifico |
| `/forgesquad backup export` | Exporta backup para arquivo .tar.gz |

## Integracao com Pipeline Runner

### No Inicio do Pipeline
```
1. Verificar se backup esta habilitado (config.yaml)
2. Criar branch forgesquad/{run_id}
3. Registrar ponto inicial no backup log
```

### Apos Cada Step
```
1. Commit automatico com mensagem padronizada
2. Push para remote (se configurado)
3. Atualizar backup log em .forgesquad/backup-log.json
```

### Em Checkpoints
```
1. Criar snapshot local (.tar.gz)
2. Tag git no checkpoint
3. Upload para remote (se configurado)
4. Informar usuario: "Backup criado: checkpoint-{step_id}"
```

### Apos Conclusao
```
1. Snapshot final com todos os artefatos
2. Tag de release: forgesquad/release/{version}
3. Mesclar branch do pipeline na main (se aprovado)
4. Limpar snapshots antigos (manter ultimos N)
```

## Backup Log

Mantido em `.forgesquad/backup-log.json`:

```json
{
  "project": "{project_name}",
  "backups": [
    {
      "id": "bkp-2026-03-23-143000",
      "type": "snapshot",
      "trigger": "checkpoint",
      "step": "step-08-approve-plan",
      "timestamp": "2026-03-23T14:30:00Z",
      "size_bytes": 2458624,
      "file": ".forgesquad/backups/2026-03-23-143000-checkpoint.tar.gz",
      "git_tag": "forgesquad/checkpoint/step-08",
      "git_sha": "a9bf0a5..."
    }
  ],
  "retention": {
    "max_snapshots": 10,
    "never_delete": ["release"]
  }
}
```

## Recuperacao

### Restaurar de Git (mais rapido)
```bash
# Ver tags disponiveis
git tag -l "forgesquad/*"

# Restaurar para um checkpoint especifico
git checkout forgesquad/checkpoint/step-08

# Restaurar para uma release
git checkout forgesquad/release/v0.3.0-beta
```

### Restaurar de Snapshot (completo)
```bash
# Via ForgeSquad
/forgesquad backup restore bkp-2026-03-23-143000

# Manual
tar -xzf .forgesquad/backups/2026-03-23-143000-checkpoint.tar.gz -C ./
```

### Restaurar de Remote (disaster recovery)
```bash
# AWS S3
aws s3 cp s3://forgesquad-backups/project/latest.tar.gz ./backup.tar.gz

# Azure Blob
az storage blob download --container forgesquad-backups --name latest.tar.gz
```

## Seguranca

- Snapshots locais sao excluidos do git via `.gitignore`
- Backups remotos sao criptografados com AES-256-GCM (se configurado)
- Chaves de acesso ao remote nunca ficam no codigo (usar vault/env vars)
- Audit trail registra cada operacao de backup/restore

## Configuracao Padrao

Adicionado automaticamente ao `config.yaml` de todo projeto:

```yaml
governance:
  backup:
    enabled: true
    auto_commit: true           # Commit apos cada step
    auto_snapshot: true         # Snapshot apos cada checkpoint
    max_local_snapshots: 10     # Manter ultimos 10
    snapshot_triggers:
      - checkpoint              # Em cada checkpoint
      - phase_complete          # Ao final de cada fase
      - sprint_complete         # Ao final de cada sprint
      - before_destructive      # Antes de operacoes destrutivas
    retention:
      never_delete: [release, final_report]
    remote:
      enabled: false
```
