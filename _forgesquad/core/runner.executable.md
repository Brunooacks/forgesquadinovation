# ForgeSquad Pipeline Runner — Executable

> **SHARED FILE** — applies to ALL IDEs. Do not add IDE-specific logic here.

> **THIS FILE IS EXECUTABLE.** Follow these instructions EXACTLY as written.
> DO NOT summarize. DO NOT skip steps. DO NOT paraphrase.
> Every instruction is MANDATORY unless explicitly marked as optional.
> Every checkpoint MUST pause for user approval.
> Every artifact MUST be generated before proceeding.
> Every handoff MUST be approved by the user.

---

## PHASE 0: PRE-EXECUTION CHECKLIST

Before running ANY pipeline, complete EVERY item below. If ANY item fails, STOP and report the error.

### 0.1 — Validate Squad Files

```
ACTION: Read squads/{name}/squad.yaml
CHECK:  File exists and contains all required fields (name, code, description, agents, pipeline)
IF FAIL: STOP. Report "squad.yaml nao encontrado ou invalido em squads/{name}/"
```

```
ACTION: Read squads/{name}/pipeline/pipeline.yaml
CHECK:  File exists and contains a 'steps' array
IF FAIL: STOP. Report "pipeline.yaml nao encontrado em squads/{name}/pipeline/"
```

```
ACTION: For EACH step in pipeline.yaml, verify the step file exists
CHECK:  squads/{name}/pipeline/{step.file} exists for every step
IF FAIL: STOP. Report "Arquivo de step ausente: {step.file}"
```

```
ACTION: Read squads/{name}/squad-party.csv
CHECK:  File exists and contains agent entries
IF FAIL: STOP. Report "squad-party.csv nao encontrado em squads/{name}/"
```

### 0.2 — Generate Run ID and Create Directories

```
ACTION: Generate run_id = current timestamp in format YYYY-MM-DD-HHmmss
ACTION: Determine project_dir = the project root (where .forgesquad/ lives OR squads/ parent)
ACTION: Create directory: {project_dir}/.forgesquad/runs/{run_id}/
ACTION: Create directory: squads/{name}/output/{run_id}/
ACTION: Create directory: squads/{name}/reports/{run_id}/
```

### 0.3 — Initialize state.json

```
ACTION: Create squads/{name}/state.json with this EXACT structure:
```

```json
{
  "squad": "{squad_code}",
  "run_id": "{run_id}",
  "status": "initializing",
  "phase": "",
  "step": {
    "current": 0,
    "total": "{total_steps_from_pipeline}",
    "label": ""
  },
  "agents": [
    {
      "id": "{agent_id}",
      "name": "{agent_displayName}",
      "icon": "{agent_icon}",
      "status": "idle"
    }
  ],
  "handoff": null,
  "metrics": {
    "steps_completed": 0,
    "checkpoints_passed": 0,
    "review_cycles": 0,
    "artifacts_generated": [],
    "audit_entries": 0
  },
  "auto_approve_remaining": 0,
  "startedAt": "{ISO timestamp}",
  "updatedAt": "{ISO timestamp}"
}
```

### 0.4 — Initialize Audit Trail

```
ACTION: Create squads/{name}/output/{run_id}/audit-trail.json
CONTENT: Initialize as empty JSON array: []

ACTION: Append FIRST audit entry:
  entry_id: generate UUID v4
  sequence_number: 1
  timestamp: current ISO timestamp (UTC)
  run_id: {run_id}
  squad: {squad_code}
  phase: "initialization"
  step_id: "pre-exec"
  step_name: "Pipeline Initialization"
  agent_id: "pipeline-runner"
  agent_name: "Pipeline Runner"
  action_type: "pipeline_started"
  artifact_path: null
  artifact_hash_sha256: null
  status: "success"
  reviewer: null
  approval_timestamp: null
  related_entry_id: null
  notes: "Pipeline started. Steps: {total}. Squad: {squad_code}. Run: {run_id}"
```

### 0.5 — Load Configuration

```
ACTION: Read _forgesquad/config.yaml
EXTRACT: governance.embedded_intelligence (list of intelligence files)
EXTRACT: execution.modes (inline, subagent, ralph_loop agent mappings)
EXTRACT: capabilities (provider mappings)
EXTRACT: governance.backup (backup settings)
```

### 0.6 — Load Embedded Intelligence

```
ACTION: For EACH file in governance.embedded_intelligence:
  1. Read the file
  2. Check frontmatter for 'injected_into' field
  3. Store mapping: {agent_type} -> {intelligence_content}
  4. This content will be injected when the agent is loaded (Phase 1, Step Execution)
```

### 0.7 — Present Squad Summary and Get Approval

```
ACTION: Present this to the user:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Iniciando Squad: {squad_name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Pipeline: {total_steps} steps, {checkpoint_count} checkpoints
  Agentes:
    {icon} {agent_name} [{execution_mode}]
    ...

  Run ID: {run_id}
  Output: squads/{name}/output/{run_id}/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Iniciar execucao? [S]im / [N]ao
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MANDATORY: WAIT for user response.
DO NOT proceed until user says S/Sim/Yes.
If user says N/Nao/No: STOP pipeline. Update state.json status to "cancelled".
```

### 0.8 — Update State to Running

```
ACTION: Update state.json:
  status: "running"
  updatedAt: current ISO timestamp
```

---

## PHASE 1: PIPELINE EXECUTION

For EACH step in pipeline.yaml, in order, execute the following sub-phases. DO NOT skip any sub-phase. DO NOT reorder steps.

---

### 1.1 — STEP PRE-PROCESSING

Execute this BEFORE every step, no exceptions.

```
ACTION: Update state.json:
  step.current = {step_number} (1-indexed)
  step.label = "{step_name}"
  phase = "{step_phase}" (from pipeline.yaml or inferred from step position)
  updatedAt = current ISO timestamp

ACTION: Append audit entry:
  action_type: "step_started"  (use "checkpoint_reached" if type == checkpoint)
  step_id: "{step.id}"
  step_name: "{step.name}"
  agent_id: "{step.agent}" (or "pipeline-runner" for checkpoints)
  agent_name: "{agent display name}"
  status: "pending"

ACTION: Announce to user:
  "Step {current}/{total}: {step_name}"
  "Agente: {icon} {agent_name}" (or "Checkpoint" if type == checkpoint)
```

---

### 1.2 — STEP EXECUTION (by type)

Read the step's `type` field from pipeline.yaml. Execute the MATCHING section below. Execute ONLY the matching section.

---

#### TYPE: checkpoint

```
MANDATORY: This is a user approval gate. You MUST stop and wait.

ACTION: Read the step file: squads/{name}/pipeline/{step.file}
ACTION: Present the checkpoint content to the user

ACTION: Update state.json:
  status: "checkpoint"

ACTION: If the step file contains a 'decisions' section or numbered options:
  Present them as a numbered list for the user to choose from.

ACTION: Present approval prompt:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CHECKPOINT: {step_name}
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {checkpoint content / decision options}
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [S]im — Aprovar e continuar
  [N]ao — Rejeitar (fornecer feedback)
  [R]evisar — Ver detalhes antes de decidir
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MANDATORY: STOP. WAIT for user input. DO NOT proceed.

IF user responds S/Sim/Yes:
  1. Append audit entry: action_type = "checkpoint_approved", reviewer = "user"
  2. Save checkpoint report: squads/{name}/output/{run_id}/checkpoint-{step_id}.md
     Content: checkpoint name, user decision, timestamp, any decision details
  3. Update state.json: status = "running", metrics.checkpoints_passed += 1

IF user responds N/Nao/No:
  1. Ask user for feedback: "Qual o motivo da rejeicao?"
  2. WAIT for user feedback.
  3. Append audit entry: action_type = "checkpoint_rejected", reviewer = "user", notes = {feedback}
  4. Save rejection to checkpoint report
  5. Determine action:
     - If this checkpoint blocks a previous step: re-execute that step with feedback
     - If this checkpoint is informational: ask user how to proceed

IF user responds R/Revisar:
  1. Show full step file content
  2. Show any related artifacts from previous steps
  3. Ask again: [S]im / [N]ao
  4. WAIT for response
```

---

#### EXECUTION: inline

```
ACTION: Load agent persona
  1. Read agent file: squads/{name}/agents/{step.agent}.agent.md
  2. Read agent row from squad-party.csv for display name and icon
  3. Inject embedded intelligence:
     - Check the agent type against intelligence mappings from Phase 0.6
     - If match: append intelligence content to agent context
  4. Inject best-practice context:
     - If step file frontmatter has 'best_practice:' field
     - Read: _forgesquad/core/best-practices/{practice}.md
     - Append to agent context
  5. Resolve capabilities:
     - Read agent's capabilities from squad.yaml or agent catalog
     - For each capability: check config.yaml for configured provider
     - If provider has SKILL.md in skills/{provider}/: load it
     - If no provider: agent uses native AI reasoning

ACTION: Switch to agent persona
  Adopt the agent's identity, communication style, and principles.
  Announce: "{icon} {agent_name} assumindo..."

ACTION: Read step file: squads/{name}/pipeline/{step.file}
ACTION: Execute the step instructions as the agent
ACTION: Generate output

ACTION: Save output artifact:
  File: squads/{name}/output/{run_id}/step-{nn}-{step.id}.md
  Where {nn} = zero-padded step number (01, 02, etc.)
  Content: The full output produced by the agent for this step

ACTION: Compute SHA-256 hash of the artifact content
  (Use shell command: echo -n "{content}" | shasum -a 256 | cut -d' ' -f1)

ACTION: Append audit entry:
  action_type: "artifact_created"
  artifact_path: "output/{run_id}/step-{nn}-{step.id}.md"
  artifact_hash_sha256: {computed hash}
  status: "success"

ACTION: Present output summary to user (3-5 lines max, not the full artifact)
```

---

#### EXECUTION: subagent

```
ACTION: Load agent persona (same as inline Step 1-5 above)

ACTION: Inform user:
  "{icon} {agent_name} trabalhando em background..."

ACTION: Execute step instructions as the agent
  (Run as a background task if the IDE supports it, otherwise run inline)

ACTION: Save output artifact:
  File: squads/{name}/output/{run_id}/step-{nn}-{step.id}.md

ACTION: Compute SHA-256 hash of artifact content

ACTION: Append audit entry:
  action_type: "artifact_created"
  artifact_path: "output/{run_id}/step-{nn}-{step.id}.md"
  artifact_hash_sha256: {computed hash}
  status: "success"

ACTION: Present completion summary to user:
  "{icon} {agent_name} concluiu."
  "{brief 2-3 line summary of output}"
  "Artefato: squads/{name}/output/{run_id}/step-{nn}-{step.id}.md"
```

---

#### EXECUTION: ralph-loop

```
ACTION: Load agent persona (same as inline Step 1-5 above)

ACTION: Read Ralph Loop engine:
  1. Check if _forgesquad/core/ralph.engine.md exists
  2. If YES: load Ralph engine instructions
  3. If NO: FALLBACK to inline execution (log warning in audit trail)

ACTION: Announce:
  "{icon} {agent_name} iniciando implementacao iterativa (Ralph Loop)..."

ACTION: Generate prd.json from step requirements:
  1. Read step file for requirements/user stories
  2. Break down into individual stories with acceptance criteria
  3. Save as: squads/{name}/output/{run_id}/step-{nn}-prd.json

ACTION: Execute Ralph Loop iterations:
  max_iterations = config.yaml -> execution.ralph_loop.default_max_iterations (default: 10)
  quality_gates = config.yaml -> execution.ralph_loop.default_quality_gates

  FOR each iteration (1 to max_iterations):
    1. Pick the highest priority incomplete story from prd.json
    2. Implement the story
    3. Run quality gates (typecheck, lint, test as configured)
    4. IF all gates pass:
       a. Mark story as complete in prd.json
       b. Commit changes (if backup.auto_commit is true):
          git add -A && git commit -m "forgesquad: {story_name} - {agent_name} - iteration {n}"
       c. Update state.json with ralph progress
       d. Append audit entry: action_type = "artifact_created", notes = "Ralph iteration {n}: {story_name}"
    5. IF any gate fails:
       a. Log failure in audit trail: notes = "Quality gate failed: {gate_name}: {error}"
       b. Retry on next iteration with targeted fix
    6. IF all stories complete: BREAK loop early

ACTION: Save all outputs:
  File: squads/{name}/output/{run_id}/step-{nn}-{step.id}.md
  Content: Summary of all iterations, stories completed, quality gate results

ACTION: Compute SHA-256 hash of artifact

ACTION: Append audit entry:
  action_type: "artifact_created"
  artifact_path: "output/{run_id}/step-{nn}-{step.id}.md"
  artifact_hash_sha256: {hash}
  notes: "Ralph Loop completed. Iterations: {count}. Stories: {completed}/{total}."

ACTION: Present completion summary:
  "{icon} {agent_name} concluiu implementacao."
  "Iteracoes: {count}/{max}"
  "Stories concluidas: {completed}/{total}"
  "Quality gates: {pass_count} passed, {fail_count} failed"
```

---

### 1.3 — STEP POST-PROCESSING

Execute this AFTER every step, no exceptions.

```
ACTION: Update state.json:
  step.current = {step_number} (remains current until next step starts)
  metrics.steps_completed += 1
  metrics.artifacts_generated: append artifact path
  updatedAt = current ISO timestamp

ACTION: Append audit entry:
  action_type: "step_completed" (use "artifact_approved" if coming from review)
  step_id: "{step.id}"
  status: "success"

ACTION: Check for veto conditions:
  1. Read the step file
  2. Look for "## Veto Conditions" section
  3. IF found: evaluate each condition against the output
  4. IF any veto triggered:
     a. Announce: "VETO: {condition} detectada no output de {agent_name}"
     b. Append audit: action_type = "veto_triggered", notes = {condition}
     c. Agent retries with targeted correction (max 2 retries)
     d. IF resolved: append audit: action_type = "veto_resolved"
     e. IF not resolved after 2 retries: escalate to user
        "VETO nao resolvido apos 2 tentativas. O que deseja fazer?"
        "[P]ular / [A]bortar / [M]anual — resolver manualmente"
        WAIT for user response.
```

---

### 1.4 — HANDOFF APPROVAL GATE

Execute this AFTER step post-processing, ONLY when the next step has a DIFFERENT agent.

```
CHECK: Is there a next step in the pipeline?
  IF NO: skip to Phase 2 (Pipeline Completion)

CHECK: Does the next step have a DIFFERENT agent than the current step?
  IF NO: skip this gate, proceed to next step
  IF YES: execute the handoff gate below

CHECK: Is auto_approve_remaining > 0 in state.json?
  IF YES:
    1. Decrement auto_approve_remaining
    2. Update state.json
    3. Append audit: action_type = "handoff_auto_approved"
    4. Log: "Handoff auto-aprovado ({remaining} restantes)"
    5. Skip the approval prompt below
    6. Proceed to next step

MANDATORY HANDOFF GATE:

ACTION: Update state.json:
  handoff.from = "{current_agent_id}"
  handoff.to = "{next_agent_id}"
  handoff.status = "pending_approval"
  handoff.artifact = "{artifact_path}"

ACTION: Present to user:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
APROVACAO DE HANDOFF — Step {current} -> Step {next}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Agente anterior: {icon} {current_agent_name}
  Entregavel: {artifact_path}
  Status: Concluido

Proximo agente: {icon} {next_agent_name}
  Tarefa: {next_step_name}

Resumo do que foi produzido:
  {1-3 line summary of the artifact}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Aprovar handoff? [S]im / [N]ao / [R]evisar / [A]uto (aprovar proximos N)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MANDATORY: STOP. WAIT for user response. DO NOT proceed.

IF user responds S/Sim/Yes:
  1. Update state.json: handoff.status = "approved", handoff.approvedAt = timestamp
  2. Append audit: action_type = "handoff_approved", reviewer = "human"
  3. Proceed to next step

IF user responds N/Nao/No:
  1. Ask: "Qual o feedback para {current_agent_name}?"
  2. WAIT for user feedback
  3. Append audit: action_type = "handoff_rejected", reviewer = "human", notes = {feedback}
  4. Update state.json: handoff.status = "rejected"
  5. Re-execute the current step with user feedback appended to instructions
  6. Increment metrics.review_cycles
  7. IF this is the 2nd rejection for this handoff:
     "Segundo ciclo de revisao. O que deseja fazer?"
     "[R]etentar / [P]ular / [A]bortar"
     WAIT for user response.

IF user responds R/Revisar:
  1. Display the FULL artifact content
  2. Ask again: [S]im / [N]ao
  3. WAIT for response

IF user responds A/Auto followed by a number (e.g., "A 5" or "auto 3"):
  1. Set state.json: auto_approve_remaining = {number}
  2. Append audit: action_type = "handoff_auto_approved", notes = "Auto-approve enabled for {number} handoffs"
  3. Proceed to next step
```

---

### 1.5 — BACKUP TRIGGER

Execute this AFTER handoff gate (or after post-processing if no handoff).

```
CHECK: Is governance.backup.auto_commit == true in config.yaml?
  IF YES AND project is a git repo:
    git add -A
    git commit -m "forgesquad: {step_name} - {agent_name} - {run_id}"

CHECK: Is this step a checkpoint AND governance.backup.auto_snapshot == true?
  IF YES:
    1. Create snapshot tag: git tag forgesquad/checkpoint/{step_id}
    2. Log: "Backup criado: checkpoint-{step_id}"
```

---

### 1.6 — LOOP CONTROL

```
ACTION: Increment step counter
ACTION: Check if there are more steps in pipeline.yaml
  IF YES: Go back to 1.1 (Step Pre-Processing) for the next step
  IF NO: Proceed to Phase 2 (Pipeline Completion)
```

---

## PHASE 2: PIPELINE COMPLETION

Execute ALL of the following when the last step completes.

### 2.1 — Generate Final Report

```
ACTION: Create final report at:
  squads/{name}/reports/{run_id}/final-report.md

CONTENT:
  # ForgeSquad — Relatorio Final
  ## Squad: {squad_name}
  ## Run: {run_id}
  ## Data: {current date/time}

  ### Resumo
  - Status: Concluido
  - Total de steps: {total}
  - Steps concluidos: {completed}
  - Checkpoints aprovados: {checkpoints_passed}
  - Ciclos de revisao: {review_cycles}
  - Artefatos gerados: {artifact_count}

  ### Artefatos Gerados
  | Step | Artefato | Agente |
  |------|----------|--------|
  {for each artifact in metrics.artifacts_generated}

  ### Trilha de Auditoria
  Total de entradas: {audit_entries}
  Arquivo: squads/{name}/output/{run_id}/audit-trail.json

  ### Decisoes em Checkpoints
  {list each checkpoint decision with timestamp}

  ### Handoffs
  {list each handoff with approval status}
```

### 2.2 — Final Backup

```
CHECK: Is the project a git repo AND backup.auto_commit?
  IF YES:
    git add -A
    git commit -m "forgesquad: pipeline completed - {squad_code} - {run_id}"
    git tag forgesquad/release/{run_id}
```

### 2.3 — Update State to Completed

```
ACTION: Update state.json:
  status: "completed"
  updatedAt: current ISO timestamp
```

### 2.4 — Final Audit Entry

```
ACTION: Append audit entry:
  action_type: "pipeline_completed"
  status: "success"
  notes: "Pipeline completed. Steps: {completed}/{total}. Checkpoints: {passed}. Artifacts: {count}. Review cycles: {review_cycles}."
```

### 2.5 — Validate Audit Trail

```
ACTION: Read the full audit-trail.json
CHECK 1: sequence_numbers are consecutive (1, 2, 3, ...) with no gaps
CHECK 2: timestamps are in chronological order
CHECK 3: every checkpoint_reached has a checkpoint_approved or checkpoint_rejected
CHECK 4: every veto_triggered has a veto_resolved (if applicable)
CHECK 5: every artifact in output/ has an artifact_created entry

IF any check fails: WARN the user (do not block completion)
  "AVISO: Inconsistencia detectada na trilha de auditoria: {details}"
```

### 2.6 — Present Completion Summary

```
ACTION: Present to user:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Pipeline concluido!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Squad: {squad_name}
  Run: {run_id}
  Duracao: {elapsed time}

  Steps concluidos: {completed}/{total}
  Checkpoints aprovados: {checkpoints_passed}
  Artefatos gerados: {artifact_count}
  Ciclos de revisao: {review_cycles}

  Pasta de output: squads/{name}/output/{run_id}/
  Relatorio final: squads/{name}/reports/{run_id}/final-report.md
  Trilha de auditoria: squads/{name}/output/{run_id}/audit-trail.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
O que deseja fazer?
  [1] Executar novamente
  [2] Ver relatorio detalhado
  [3] Editar configuracao do squad
  [4] Voltar ao menu
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WAIT for user response.
```

---

## RESUME PROTOCOL

When resuming a pipeline with `--resume <run-id>`:

```
ACTION: Read squads/{name}/state.json
CHECK:  state.run_id matches the provided run-id
IF FAIL: STOP. Report "Run ID nao corresponde ao estado salvo."

ACTION: Find the last completed step:
  last_completed = state.step.current where last audit entry is "step_completed"

ACTION: Set the starting point to: last_completed + 1

ACTION: Present resume summary:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Resumindo pipeline: {squad_name}
  Run: {run_id}
  Ultimo step concluido: Step {n} — {step_name}
  Retomando de: Step {n+1} — {next_step_name}
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Continuar? [S]im / [N]ao
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WAIT for user response.
IF S: Proceed to Phase 1, starting from the resume step
IF N: STOP
```

---

## ERROR HANDLING

These rules apply at ALL times during execution.

### Step File Missing

```
IF a step file cannot be read:
  1. STOP pipeline execution
  2. Report: "ERRO: Arquivo de step nao encontrado: {file_path}"
  3. Append audit: action_type = "step_started", status = "failure", notes = "File not found: {path}"
  4. Update state.json: status = "failed"
  5. Offer options: "[R]etentar / [P]ular / [A]bortar"
  6. WAIT for user response
```

### Agent File Missing

```
IF an agent file cannot be read:
  1. WARN: "AVISO: Arquivo de agente nao encontrado: {file_path}. Usando persona generica."
  2. Continue with a generic agent persona based on the agent type from the catalog
  3. Append audit: notes = "Agent file missing, using generic persona"
```

### Subagent Failure

```
IF a subagent execution fails:
  1. Log the error in audit trail
  2. Retry ONCE with the same instructions
  3. IF retry fails:
     a. Report: "ERRO: Agente {name} falhou apos retry."
     b. Offer: "[R]etentar / [P]ular / [A]bortar"
     c. WAIT for user response
```

### External Tool Unavailable

```
IF a capability provider (Devin, Copilot, StackSpot, etc.) is unavailable:
  1. WARN: "Ferramenta {provider} indisponivel. Usando raciocinio nativo do agente."
  2. Fall back to native AI reasoning
  3. Log in audit trail: notes = "Provider {provider} unavailable, fallback to native"
```

### Pipeline Abort

```
IF user chooses to abort at any point:
  1. Update state.json: status = "aborted"
  2. Append audit: action_type = "pipeline_completed", status = "failure", notes = "Aborted by user at step {n}"
  3. Save all artifacts generated so far
  4. Present abort summary:
     "Pipeline abortado no Step {n}. Artefatos salvos em squads/{name}/output/{run_id}/"
     "Para retomar: /forgesquad run {name} --resume {run_id}"
```

---

## CRITICAL RULES — READ THIS

1. **NEVER skip a checkpoint.** Every checkpoint MUST pause for user input. There are ZERO exceptions.
2. **NEVER skip a handoff gate.** Every agent-to-agent transition MUST be approved (unless auto-approve is active).
3. **ALWAYS generate artifacts.** Every step produces a file. No exceptions.
4. **ALWAYS update state.json.** Before AND after every step.
5. **ALWAYS append to audit trail.** Every action gets logged. Append-only. Never modify existing entries.
6. **ALWAYS compute artifact hashes.** Every artifact gets a SHA-256 hash in the audit trail.
7. **NEVER proceed on error without user decision.** Errors always pause for user input.
8. **NEVER modify the pipeline order.** Steps execute in the order defined in pipeline.yaml.
9. **NEVER impersonate multiple agents simultaneously.** One agent at a time. Switch fully.
10. **ALWAYS present output summaries.** The user must see what each step produced before continuing.
