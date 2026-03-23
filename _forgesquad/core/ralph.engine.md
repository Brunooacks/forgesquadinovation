# Ralph Loop Engine — Autonomous Iterative Implementation

> **SHARED FILE** — applies to ALL IDEs. Do not add IDE-specific logic here.

The Ralph Loop Engine enables autonomous iterative implementation within ForgeSquad pipelines.
Instead of a single agent attempt, it breaks complex work into user stories and runs fresh
AI sessions iteratively until all stories pass quality gates.

Inspired by [snarktank/ralph](https://github.com/snarktank/ralph).

## Detection

When a pipeline step has `execution: ralph-loop` in its frontmatter, the Pipeline Runner
delegates execution to this engine instead of using inline or subagent mode.

## Configuration

Ralph configuration is read from multiple sources (in order of precedence):

1. **Step frontmatter** `ralph:` block (highest priority)
2. **squad.yaml** `ralph:` section
3. **`_forgesquad/config.yaml`** `ralph:` section (defaults)

```yaml
# Step frontmatter example
---
execution: ralph-loop
agent: squads/{code}/agents/dev-backend.agent.md
inputFile: squads/{code}/output/{run_id}/technical-spec.md
outputFile: squads/{code}/output/{run_id}/implementation/
ralph:
  max_iterations: 10
  quality_gates:
    - typecheck
    - lint
    - test
  story_source: auto       # auto | prd
  branch_prefix: ralph     # git branch prefix
---
```

## Initialization

When the Pipeline Runner encounters `execution: ralph-loop`:

1. **Create working directory**:
   ```
   squads/{name}/output/{run_id}/_ralph/{step-id}/
   ├── prd.json           # User stories to implement
   ├── progress.txt       # Append-only learnings log
   └── AGENTS.md          # Discovered patterns
   ```

2. **Generate or load prd.json**:

   **If `story_source: auto`** (default):
   - Read the step's `inputFile` (technical spec, architecture doc, or requirements)
   - Read the agent persona for domain context
   - Generate `prd.json` following this structure:
   ```json
   {
     "project": "{squad name}",
     "branchName": "ralph/{step-id}",
     "description": "{step description from pipeline.yaml}",
     "userStories": [
       {
         "id": "US-001",
         "title": "{story title}",
         "description": "As a {role}, I want {feature} so that {benefit}",
         "acceptanceCriteria": [
           "Criterion 1",
           "Criterion 2",
           "Typecheck passes",
           "Tests pass"
         ],
         "priority": 1,
         "passes": false,
         "notes": ""
       }
     ]
   }
   ```

   **Story sizing rules** (critical for success):
   - Each story MUST be completable in a single AI context window
   - Good size: one database table, one API endpoint, one UI component
   - Too large: "build entire dashboard", "add authentication" — split these
   - Order by dependency: schema before backend, backend before frontend
   - Always include quality gate criteria in acceptanceCriteria

   **If `story_source: prd`**:
   - Read existing `prd.json` from the step's `inputFile` path
   - Validate structure and story sizing

3. **Initialize progress.txt**:
   ```
   # Ralph Loop Progress — {step name}
   # Squad: {squad name} | Run: {run_id} | Step: {step-id}
   # Started: {ISO timestamp}

   ## Codebase Patterns
   (Consolidated patterns discovered across iterations — updated by each iteration)

   ---
   ```

4. **Initialize AGENTS.md**:
   ```markdown
   # Agent Learnings — {step name}

   Patterns and learnings discovered during implementation.
   Each iteration appends discoveries here for future iterations.
   ```

5. **Update state.json** with ralph sub-state:
   ```json
   "ralph": {
     "stepId": "{step-id}",
     "status": "initializing",
     "iteration": 0,
     "maxIterations": 10,
     "storiesTotal": 5,
     "storiesComplete": 0,
     "currentStory": null,
     "qualityGates": ["typecheck", "lint", "test"],
     "startedAt": "{ISO timestamp}"
   }
   ```

## Loop Execution

For each iteration (up to `max_iterations`):

### 1. Check completion
- Read `prd.json`
- If ALL stories have `"passes": true` → exit loop with SUCCESS
- If no incomplete stories remain → exit loop with SUCCESS

### 2. Select next story
- Find the highest-priority story with `"passes": false`
- Set as `currentStory` in state.json

### 3. Build iteration prompt
- Read `_forgesquad/core/prompts/ralph-iteration.prompt.md`
- Inject:
  - Agent persona (from step's agent file)
  - Company context
  - Squad tech stack
  - Current `prd.json` state
  - Current `progress.txt` content
  - Current `AGENTS.md` content
  - The specific story to implement
  - Quality gate requirements

### 4. Execute iteration
- Spawn a fresh AI session (Claude Code or Amp based on config)
- The session receives the composed prompt
- The session implements the story, runs quality gates, and reports back
- Each iteration gets CLEAN CONTEXT — no carry-over from previous iterations
- Memory persists ONLY through: git history, progress.txt, prd.json, AGENTS.md

### 5. Quality gates
After the AI session completes:
- **typecheck**: Run type checker for the project's language (tsc, mypy, etc.)
- **lint**: Run linter (eslint, pylint, golangci-lint, etc.)
- **test**: Run test suite (unit + integration)

If ALL gates pass:
- Mark story as `"passes": true` in prd.json
- Commit changes with message: `feat: [US-{id}] - {title}`
- Append iteration summary to progress.txt

If ANY gate fails:
- Keep `"passes": false`
- Append failure details to progress.txt
- Next iteration will retry with failure context

### 6. Update state.json
```json
"ralph": {
  "status": "running",
  "iteration": 3,
  "storiesComplete": 2,
  "storiesTotal": 5,
  "currentStory": "US-003",
  "lastGateResult": "pass|fail",
  "updatedAt": "{ISO timestamp}"
}
```

### 7. Log to audit trail
If audit trail is enabled:
```json
{
  "action_type": "ralph_iteration_completed",
  "step_id": "{step-id}",
  "iteration": 3,
  "story_id": "US-003",
  "quality_gates": { "typecheck": "pass", "lint": "pass", "test": "pass" },
  "story_passed": true,
  "artifact_hash_sha256": "{hash of changed files}"
}
```

## Completion

### Success (all stories pass)
1. Update state.json: `ralph.status = "completed"`
2. Log `ralph_loop_completed` to audit trail
3. Collect all outputs to the step's `outputFile` directory
4. Write completion summary to progress.txt
5. Return control to Pipeline Runner — step is DONE
6. Present summary:
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   🔄 Ralph Loop Complete — {step name}
   📊 Iterations: {count}/{max}
   ✅ Stories completed: {total}
   🧪 Quality gates: All passing
   📁 Output: {outputFile path}
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

### Max iterations reached (incomplete)
1. Update state.json: `ralph.status = "max_iterations_reached"`
2. Pause pipeline at CHECKPOINT:
   ```
   ⚠️ Ralph Loop reached max iterations ({max}) for {step name}
   Stories complete: {complete}/{total}
   Remaining: {list incomplete story IDs and titles}

   Options:
   1. Continue with {N} more iterations
   2. Skip remaining stories and proceed
   3. Abort pipeline
   ```
3. Wait for user decision
4. If continue: reset iteration counter, resume loop
5. If skip: mark step as partial, proceed to next step
6. If abort: stop pipeline

### Failure (critical error)
1. Update state.json: `ralph.status = "failed"`
2. Log error to audit trail
3. Present error to user with context from progress.txt
4. Offer: retry step, skip, or abort

## Integration with Pipeline Steps

### Example: forge-engineering with Ralph

The implementation steps (09, 10) can use ralph-loop:

```yaml
# pipeline.yaml (modified steps)
- id: step-09
  name: "Backend Implementation"
  type: agent
  file: steps/step-09-backend-impl.md
  agent: dev-backend
  execution: ralph-loop          # NEW — was "inline"
  phase: implementation
  depends_on: step-08
  ralph:
    max_iterations: 15
    quality_gates: [typecheck, lint, test]
    story_source: auto

- id: step-10
  name: "Frontend Implementation"
  type: agent
  file: steps/step-10-frontend-impl.md
  agent: dev-frontend
  execution: ralph-loop          # NEW — was "inline"
  phase: implementation
  depends_on: step-08
  ralph:
    max_iterations: 15
    quality_gates: [typecheck, lint, test]
    story_source: auto
```

### Backward Compatibility

- Steps WITHOUT `execution: ralph-loop` are unchanged
- The `ralph:` block in step frontmatter is optional
- Existing squads continue to work with inline/subagent modes
- Ralph Loop is an OPT-IN feature per step

## Limitations

- Ralph works best for well-defined implementation tasks with clear specs
- Story sizing is critical — oversized stories will fail or produce low-quality code
- Each iteration has clean context — complex cross-cutting changes may need manual intervention
- Quality gates must be configured for the specific project's toolchain
- Ralph Loop adds latency (multiple iterations) but improves code quality through incremental validation
