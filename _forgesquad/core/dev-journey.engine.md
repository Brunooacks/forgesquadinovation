# Dev Journey & Release Roadmap Engine

> **SHARED FILE** — applies to ALL IDEs. Do not add IDE-specific logic here.

The Dev Journey Engine generates a visual development roadmap and structured release plan
based on the squad's methodology, agents, and pipeline configuration.

## When to Generate

The Dev Journey is generated at TWO points:

1. **Squad Creation** (Architect Phase 5): Generate initial roadmap as part of squad files
2. **Pipeline Start** (after step-00 Estimation): Refine roadmap with estimation data

## Inputs

- `squad.yaml`: methodology, agents, pipeline, project_type
- `pipeline.yaml`: steps, phases, dependencies
- `_forgesquad/methodologies/{methodology}.yaml`: grouping and ceremony rules
- `output/estimation/project-estimation.md`: effort estimates (if available)

## Outputs

Two files generated to `squads/{name}/output/{run_id}/`:

1. **`dev-journey.md`** — Visual markdown roadmap
2. **`release-plan.yaml`** — Structured release plan

## Generation Logic by Methodology

### Default (Linear Pipeline)

```markdown
# Development Journey — {project_name}

## Timeline
Phase 1: {phase_name} → Steps {1-N} → Gate: Checkpoint
Phase 2: {phase_name} → Steps {N-M} → Gate: Checkpoint
...
Phase K: {phase_name} → Steps {M-Z} → Gate: Final Report

## Release
Single release at pipeline completion: v1.0.0
```

Release plan:
```yaml
releases:
  - version: "1.0.0"
    label: "Release"
    trigger: pipeline_completion
    scope: "All pipeline steps"
    quality_gates: [all_steps_completed, all_reviews_passed]
```

### Waterfall

```markdown
# Development Journey — {project_name} (Waterfall)

## Phase 1: Requirements (Estimated: {duration})
├── Step: Project Briefing → Agent: Business Analyst
├── Step: Requirements Gathering → Agent: Business Analyst
├── Step: Requirements Approval → Gate: Formal Sign-off
└── Deliverable: Requirements Specification Document
    ↓ Phase Gate (Formal Sign-off Required)

## Phase 2: Design (Estimated: {duration})
├── Step: Architecture Design → Agent: Architect
├── Step: Architecture Review → Gate: Formal Sign-off
└── Deliverable: Architecture Specification + ADRs
    ↓ Phase Gate (Formal Sign-off Required)

## Phase 3: Implementation (Estimated: {duration})
├── Step: Backend Implementation → Agent: Dev Backend
├── Step: Frontend Implementation → Agent: Dev Frontend
├── Step: Implementation Checkpoint → Gate: Code Freeze
└── Deliverable: Complete Codebase
    ↓ Phase Gate (Formal Sign-off Required)

## Phase 4: Verification (Estimated: {duration})
├── Step: Automated Tests → Agent: QA Engineer
├── Step: Performance Tests → Agent: QA Engineer
├── Step: Code Review → Agent: Tech Lead + Architect
└── Deliverable: Test Report + Review Report
    ↓ Phase Gate (Formal Sign-off Required)

## Phase 5: Deployment (Estimated: {duration})
├── Step: Documentation → Agent: Tech Writer
├── Step: Go/No-Go → Gate: Final Approval
├── Step: Deploy → Agent: Dev Backend
└── Deliverable: Production Release v1.0.0

## Release: v1.0.0 (Big-Bang)
Single release after all phases complete.
```

Release plan:
```yaml
releases:
  - version: "1.0.0"
    label: "GA"
    trigger: phase_gate_deployment_approved
    scope: "All phases complete"
    quality_gates: [all_phase_gates_approved, all_tests_passed, security_scan_clean]
```

### Scrum

```markdown
# Development Journey — {project_name} (Scrum)

## Sprint 1: Foundation
├── 🎯 Goal: Project setup, DB schema, authentication
├── Steps: {list of steps assigned to sprint 1}
├── Agents: Architect, Dev Backend
├── Ceremonies: Planning → Daily x{N} → Review → Retro
└── Release: v0.1.0-alpha
    ↓ Sprint Boundary

## Sprint 2: Core Features
├── 🎯 Goal: Business logic APIs, core services
├── Steps: {list of steps assigned to sprint 2}
├── Agents: Dev Backend, Business Analyst
├── Ceremonies: Planning → Daily x{N} → Review → Retro
└── Release: v0.2.0-alpha
    ↓ Sprint Boundary

## Sprint 3: User Interface
├── 🎯 Goal: Frontend components, integration
├── Steps: {list of steps assigned to sprint 3}
├── Agents: Dev Frontend, Dev Backend
├── Ceremonies: Planning → Daily x{N} → Review → Retro
└── Release: v0.3.0-beta
    ↓ Sprint Boundary

## Sprint 4: Quality & Polish
├── 🎯 Goal: Tests, security, performance, docs
├── Steps: {list of steps assigned to sprint 4}
├── Agents: QA Engineer, Tech Writer, Architect
├── Ceremonies: Planning → Daily x{N} → Review → Retro
└── Release: v1.0.0-rc
    ↓ Sprint Boundary

## Sprint 5: Release
├── 🎯 Goal: Deploy, monitoring, final report
├── Steps: {list of steps assigned to sprint 5}
├── Agents: Dev Backend, Project Manager
├── Ceremonies: Planning → Daily x{N} → Review → Retro
└── Release: v1.0.0 (GA)
```

Release plan:
```yaml
releases:
  - version: "0.1.0-alpha"
    label: "Alpha"
    trigger: sprint_1_review_approved
    scope: [infrastructure, schema, auth]
    agents: [architect, dev-backend]
    quality_gates: [typecheck, lint, unit_tests]

  - version: "0.2.0-alpha"
    label: "Alpha 2"
    trigger: sprint_2_review_approved
    scope: [apis, business_logic]
    quality_gates: [typecheck, lint, unit_tests, integration_tests]

  - version: "0.3.0-beta"
    label: "Beta"
    trigger: sprint_3_review_approved
    scope: [frontend, integration]
    quality_gates: [typecheck, lint, tests, e2e_smoke]

  - version: "1.0.0-rc"
    label: "Release Candidate"
    trigger: sprint_4_review_approved
    scope: [quality, security, performance]
    quality_gates: [full_suite, security_scan, performance_test]

  - version: "1.0.0"
    label: "GA"
    trigger: sprint_5_review_approved
    scope: "All features complete"
    quality_gates: [full_suite, security_scan, production_readiness_checklist]
```

### Kanban

```markdown
# Development Journey — {project_name} (Kanban)

## Continuous Flow — Release When Ready

### Feature Batch 1: Foundation
├── Steps: {steps in batch}
├── Agents: Architect, Dev Backend
├── Flow: Backlog → In Progress → Review → Done
└── Release: v0.1.0 (when batch complete and tested)

### Feature Batch 2: Core
├── Steps: {steps in batch}
├── Agents: Dev Backend, Business Analyst
├── Flow: Backlog → In Progress → Review → Done
└── Release: v0.2.0 (when batch complete and tested)

### Feature Batch 3: UI & Integration
├── Steps: {steps in batch}
├── Agents: Dev Frontend, Dev Backend
├── Flow: Backlog → In Progress → Review → Done
└── Release: v0.3.0 (when batch complete and tested)

### Feature Batch 4: Quality & Release
├── Steps: {steps in batch}
├── Agents: QA Engineer, Tech Writer
├── Flow: Backlog → In Progress → Review → Done
└── Release: v1.0.0 (when all batches complete)

## Flow Targets
- WIP Limit: 1 step in progress
- Target Cycle Time: {estimated per step}
- Target Throughput: {steps per hour}
```

Release plan:
```yaml
releases:
  - version: "0.1.0"
    label: "Foundation"
    trigger: batch_1_done_column_complete
    scope: [infrastructure, schema, auth]
    quality_gates: [typecheck, lint, tests]

  - version: "1.0.0"
    label: "GA"
    trigger: all_batches_complete
    scope: "All features"
    quality_gates: [full_suite, security_scan, production_readiness]
```

## Template Files

### `_forgesquad/core/templates/dev-journey.template.md`
Used as the base structure — variables replaced at generation time.

### `_forgesquad/core/templates/release-plan.template.yaml`
Used as the base YAML structure for release plans.

## Integration with Pipeline Runner

After step-00 (Estimation) completes:
1. Read estimation data from `output/estimation/project-estimation.md`
2. Read methodology from `squad.yaml`
3. Generate `dev-journey.md` and `release-plan.yaml`
4. Save to `output/{run_id}/`
5. Present summary to user:
   ```
   📍 Development Journey generated!
   📄 Roadmap: output/{run_id}/dev-journey.md
   📋 Release Plan: output/{run_id}/release-plan.yaml
   🏷️  Releases planned: {count} ({version_list})
   ```
