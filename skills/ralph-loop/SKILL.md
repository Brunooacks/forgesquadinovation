---
name: "Ralph Loop"
description: "Autonomous iterative implementation engine — breaks work into stories and runs AI sessions until all pass quality gates"
type: prompt
version: "1.0.0"
category: automation
agents: [dev-backend, dev-frontend, qa-engineer]
---

# Ralph Loop — Autonomous Iterative Implementation

Ralph Loop is an execution mode that enables autonomous, iterative implementation within
ForgeSquad pipelines. Instead of a single AI attempt at a complex task, Ralph breaks work
into small user stories and runs fresh AI sessions iteratively until all stories pass
quality gates.

Inspired by [snarktank/ralph](https://github.com/snarktank/ralph) — forked to [Brunooacks/ralph](https://github.com/Brunooacks/ralph).

## When to Use Ralph Loop

- **Complex implementations**: Tasks too large for a single AI context window
- **Backend/Frontend coding**: Multi-file implementations with interdependencies
- **Infrastructure setup**: Multi-resource provisioning with dependencies
- **Quality-critical work**: When every change must pass automated quality gates

## How It Works

1. **PRD Generation**: Ralph reads the technical spec and generates a structured `prd.json` with sized user stories
2. **Iterative Execution**: For each iteration, a fresh AI session picks the highest-priority incomplete story and implements it
3. **Quality Gates**: After each iteration, automated checks (typecheck, lint, test) validate the changes
4. **Progress Tracking**: Memory persists via `progress.txt`, `prd.json`, and git history — NOT via context carry-over
5. **Completion**: When all stories pass, Ralph returns control to the pipeline

## Integration Pattern

To use Ralph Loop in a pipeline step, set `execution: ralph-loop` in the step configuration:

```yaml
# In pipeline.yaml
- id: step-09
  name: "Backend Implementation"
  type: agent
  file: steps/step-09-backend-impl.md
  agent: dev-backend
  execution: ralph-loop
  ralph:
    max_iterations: 15
    quality_gates:
      - typecheck
      - lint
      - test
    story_source: auto
```

The Pipeline Runner will detect `execution: ralph-loop` and delegate to the
Ralph Engine (`_forgesquad/core/ralph.engine.md`).

## Story Sizing Guide

Stories MUST be small enough to complete in a single AI context window.

**Good sizes** (one story each):
- Add a database table and migration
- Create one API endpoint with validation
- Build one UI component with props
- Add one integration test suite
- Configure one infrastructure resource

**Too large** (must split):
- "Build entire dashboard" → split into: schema, API, components, integration
- "Add authentication" → split into: user model, auth middleware, login UI, session handling
- "Setup CI/CD" → split into: build stage, test stage, deploy stage, monitoring

## Quality Gate Configuration

Quality gates are the feedback loops that ensure each iteration produces working code.

```yaml
quality_gates:
  - typecheck    # tsc, mypy, go vet — catches type errors
  - lint         # eslint, pylint, golangci-lint — catches style issues
  - test         # jest, pytest, go test — catches behavioral bugs
```

Custom gates can be added:
```yaml
quality_gates:
  - typecheck
  - lint
  - test
  - security_scan   # semgrep, snyk
  - build           # ensure the project builds
```

## Best Practices

- **Story ordering matters**: Schema before API, API before UI — dependency order prevents rework
- **Include acceptance criteria**: Every story should have testable criteria
- **Keep iterations short**: If a story takes too long, it's too big — split it
- **Review progress.txt**: Between iterations, learnings accumulate for better results
- **Set realistic max_iterations**: Most implementations complete in 5-10 iterations

## Limitations

- Each iteration gets clean context — no memory of previous iterations except through files
- Complex cross-cutting changes may need manual coordination between stories
- Quality gates must be preconfigured for the project's toolchain
- Ralph adds latency (multiple iterations) but improves reliability through incremental validation
- Not suitable for exploratory/research tasks — best for well-specified implementation work
