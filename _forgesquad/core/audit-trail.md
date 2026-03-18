# ForgeSquad Audit Trail Specification

> **SHARED FILE** — applies to ALL squads and pipelines. Do not add squad-specific logic here.

You are the Pipeline Runner. This document defines how you must record an immutable audit trail for every action taken during pipeline execution.

## Purpose

The audit trail provides full traceability of every artifact created, reviewed, approved, or rejected during a squad run. It satisfies regulatory requirements for software development governance, including:

- **Bacen CMN 4.893** (Resolucao Conjunta n. 6) — trilha de auditoria para sistemas criticos no setor financeiro, exigindo rastreabilidade completa de decisoes e artefatos ao longo do ciclo de vida do software.
- **LGPD (Lei 13.709/2018)** — rastreabilidade de processamento de dados pessoais, garantindo que decisoes de design que impactam dados pessoais sejam documentaveis e auditaveis.
- **ISO/IEC 27001** — controle de registros e evidencias para sistemas de gestao de seguranca da informacao.

## Audit Log Location

```
squads/{name}/output/{run_id}/audit-trail.json
```

The audit trail file is created at pipeline initialization (alongside the run folder) and appended to throughout execution.

## Immutability Rules

1. **Append-only**: Never delete, modify, or reorder existing entries in `audit-trail.json`.
2. **No overwrites**: Always append new entries to the end of the JSON array.
3. **No retroactive edits**: If a correction is needed, add a new entry with `action_type: "correction"` referencing the original entry's `entry_id`.
4. **Atomic writes**: Each entry must be written immediately after the action occurs — never batch or defer writes.
5. **Integrity**: Each entry includes a `sequence_number` (monotonically increasing from 1) to detect tampering or gaps.

## Log Entry Schema

Each entry in the `audit-trail.json` array follows this structure:

```json
{
  "entry_id": "uuid-v4",
  "sequence_number": 1,
  "timestamp": "2026-03-17T14:30:00.000Z",
  "run_id": "2026-03-17-143000",
  "squad": "forge-engineering",
  "phase": "requirements",
  "step_id": "step-02",
  "step_name": "Elicitacao de Requisitos",
  "agent_id": "business-analyst",
  "agent_name": "Ana Historias",
  "action_type": "artifact_created",
  "artifact_path": "output/requirements/user-stories.md",
  "artifact_hash_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "status": "success",
  "reviewer": null,
  "approval_timestamp": null,
  "related_entry_id": null,
  "notes": "User stories generated from project briefing"
}
```

### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `entry_id` | string (UUID v4) | Yes | Unique identifier for this log entry |
| `sequence_number` | integer | Yes | Monotonically increasing counter starting at 1 |
| `timestamp` | string (ISO 8601) | Yes | Exact time the action occurred (UTC) |
| `run_id` | string | Yes | Pipeline run identifier (format: `YYYY-MM-DD-HHmmss`) |
| `squad` | string | Yes | Squad code name |
| `phase` | string | Yes | Pipeline phase (estimation, requirements, architecture, etc.) |
| `step_id` | string | Yes | Pipeline step identifier (e.g., `step-02`) |
| `step_name` | string | Yes | Human-readable step name |
| `agent_id` | string | Yes | Agent identifier from squad-party.csv |
| `agent_name` | string | Yes | Agent display name (persona name) |
| `action_type` | string (enum) | Yes | Type of action (see Action Types below) |
| `artifact_path` | string or null | Conditional | Relative path to artifact (required for artifact_* actions) |
| `artifact_hash_sha256` | string or null | Conditional | SHA-256 hash of artifact content (required for artifact_created, artifact_approved) |
| `status` | string (enum) | Yes | Outcome: `success`, `failure`, `pending`, `skipped` |
| `reviewer` | string or null | Conditional | Agent ID or "user" who performed review (required for *_reviewed, *_approved, *_rejected) |
| `approval_timestamp` | string or null | Conditional | ISO 8601 timestamp of approval (required for *_approved actions) |
| `related_entry_id` | string or null | No | UUID of a related entry (e.g., the creation entry for an approval) |
| `notes` | string or null | No | Free-text context about the action |

## Action Types

### Artifact Lifecycle

| Action Type | When to Log | Required Fields |
|-------------|-------------|-----------------|
| `artifact_created` | Agent produces an output file | `artifact_path`, `artifact_hash_sha256` |
| `artifact_reviewed` | Agent or user reviews an artifact | `artifact_path`, `reviewer`, `related_entry_id` (original creation) |
| `artifact_approved` | Artifact passes review/quality gate | `artifact_path`, `artifact_hash_sha256`, `reviewer`, `approval_timestamp`, `related_entry_id` |
| `artifact_rejected` | Artifact fails review/quality gate | `artifact_path`, `reviewer`, `related_entry_id`, `notes` (rejection reason) |

### Checkpoints

| Action Type | When to Log | Required Fields |
|-------------|-------------|-----------------|
| `checkpoint_reached` | Pipeline arrives at a checkpoint step | `step_id`, `step_name` |
| `checkpoint_approved` | User approves at a checkpoint | `reviewer` ("user"), `approval_timestamp`, `notes` (user's decision) |
| `checkpoint_rejected` | User rejects at a checkpoint | `reviewer` ("user"), `notes` (rejection reason) |

### Handoffs

| Action Type | When to Log | Required Fields |
|-------------|-------------|-----------------|
| `handoff_initiated` | One agent's output is passed to the next | `agent_id` (source), `notes` (target agent_id) |
| `handoff_approved` | Receiving agent accepts the handoff | `agent_id` (receiver), `related_entry_id` (initiation entry) |
| `handoff_completed` | Handoff finishes and next step begins | `agent_id` (receiver), `related_entry_id` (initiation entry) |

### Veto Enforcement

| Action Type | When to Log | Required Fields |
|-------------|-------------|-----------------|
| `veto_triggered` | A veto condition is detected on agent output | `agent_id`, `notes` (veto condition description) |
| `veto_resolved` | Agent successfully corrects the veto violation | `agent_id`, `related_entry_id` (trigger entry), `notes` (resolution) |

### Pipeline Lifecycle

| Action Type | When to Log | Required Fields |
|-------------|-------------|-----------------|
| `pipeline_started` | Pipeline execution begins | `run_id`, `squad`, `notes` (pipeline mode, step count) |
| `pipeline_completed` | Pipeline finishes (success or failure) | `run_id`, `status`, `notes` (summary metrics) |

## Pipeline Runner Instructions

Follow these instructions to maintain the audit trail during pipeline execution.

### At Pipeline Start

1. Create the audit trail file:
   ```
   squads/{name}/output/{run_id}/audit-trail.json
   ```
2. Initialize with an empty JSON array: `[]`
3. Append the first entry with `action_type: "pipeline_started"`:
   - `agent_id`: "pipeline-runner"
   - `agent_name`: "Pipeline Runner"
   - `notes`: Include pipeline mode (quality-first / cost-optimized), total step count, and squad name

### Before Each Step

1. Read the step file and identify the agent
2. If this is a checkpoint step, append `checkpoint_reached`
3. If there is a handoff from the previous agent, append `handoff_initiated`

### During Step Execution

1. **When an agent produces an artifact file**:
   - Compute SHA-256 hash of the file content
   - Append `artifact_created` with path and hash

2. **When a review occurs** (code_review, architectural_review, or quality gate):
   - Append `artifact_reviewed` when review begins
   - Append `artifact_approved` or `artifact_rejected` based on outcome
   - If rejected and `on_reject` loop activates, log the rejection with reason

3. **When a veto condition triggers**:
   - Append `veto_triggered` with the condition description
   - After correction, append `veto_resolved`

### At Checkpoints

1. Append `checkpoint_reached` when presenting the checkpoint to the user
2. After user responds:
   - If approved: append `checkpoint_approved` with `reviewer: "user"`
   - If rejected: append `checkpoint_rejected` with `reviewer: "user"` and rejection reason

### At Handoffs (Between Steps)

1. When the current agent finishes and output goes to the next agent:
   - Append `handoff_initiated` (source agent, target agent in notes)
2. When the next agent acknowledges and begins:
   - Append `handoff_approved`
3. After the next step starts executing:
   - Append `handoff_completed`

### At Pipeline Completion

1. Append `pipeline_completed` with:
   - `status`: "success" or "failure"
   - `notes`: Summary including total steps executed, artifacts created, checkpoints passed, review cycles, vetos triggered/resolved

## Computing Artifact Hashes

For every artifact file, compute the SHA-256 hash of its content immediately after writing. Use the following approach:

```
# Conceptual — the Pipeline Runner should compute this inline
sha256(file_content) -> hex string
```

The hash serves as a tamper-detection mechanism. If an artifact is later modified, auditors can compare the stored hash against the current file to detect unauthorized changes.

## Audit Trail Validation

At pipeline completion (and optionally at checkpoints), validate the audit trail:

1. **Sequence integrity**: Verify `sequence_number` values are consecutive with no gaps
2. **Temporal ordering**: Verify each `timestamp` is >= the previous entry's timestamp
3. **Referential integrity**: Verify all `related_entry_id` values reference existing `entry_id` values
4. **Artifact coverage**: Verify every file in `output/` has at least one `artifact_created` entry
5. **Approval coverage**: Verify every `artifact_created` has a corresponding `artifact_approved` (flag any without)
6. **Veto resolution**: Verify every `veto_triggered` has a corresponding `veto_resolved`
7. **Checkpoint completeness**: Verify every `checkpoint_reached` has either `checkpoint_approved` or `checkpoint_rejected`

## Integration with State Management

When appending to the audit trail, also update `state.json` metrics:

```json
{
  "metrics": {
    "audit_entries": 42,
    "artifacts_created": 15,
    "artifacts_approved": 14,
    "artifacts_rejected": 1,
    "checkpoints_passed": 5,
    "vetos_triggered": 0,
    "vetos_resolved": 0
  }
}
```

## Compliance Notes

### Bacen CMN 4.893

This regulation requires financial institutions to maintain audit trails for technology risk management. The ForgeSquad audit trail satisfies:

- **Art. 3, II** — rastreabilidade de alteracoes em sistemas de informacao
- **Art. 7** — registros de auditoria com identificacao de responsaveis, datas e natureza das alteracoes
- **Art. 23** — retencao de registros por prazo minimo de 5 anos

Retention: Audit trail files must NOT be deleted for at least 5 years after pipeline completion.

### LGPD (Lei 13.709/2018)

When the pipeline processes systems that handle personal data:

- **Art. 6, X** — principio da responsabilizacao e prestacao de contas
- **Art. 37** — registro das operacoes de tratamento de dados pessoais
- **Art. 46** — medidas de seguranca para proteger dados pessoais

The audit trail provides evidence of due diligence in the software development process.

### ISO/IEC 27001

- **A.12.4** — Logging and monitoring
- **A.14.2** — Security in development and support processes

## File Format

The `audit-trail.json` file is a JSON array of entry objects:

```json
[
  { "entry_id": "...", "sequence_number": 1, ... },
  { "entry_id": "...", "sequence_number": 2, ... }
]
```

Maximum recommended file size: 10 MB per run. For very long pipelines, the Pipeline Runner should log a warning if the file exceeds 5 MB.
