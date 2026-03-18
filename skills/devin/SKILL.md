---
name: "Devin"
description: "Autonomous AI software engineer for coding tasks"
type: tool
version: "1.0.0"
category: development
agents: [dev-backend, dev-frontend, qa-engineer, tech-lead]
---

# Devin — Autonomous Coding Agent

Devin is an autonomous AI software engineer that can handle complete coding tasks independently.

## When to Use Devin

- **Autonomous implementation**: Full feature implementation from specs
- **Bug fixes**: Debugging and fixing issues with context
- **Boilerplate generation**: CRUD operations, scaffolding, repetitive patterns
- **Refactoring**: Code modernization, pattern application, cleanup
- **Test generation**: Writing test suites from specifications

## Integration Pattern

When a squad agent needs to delegate a coding task to Devin:

1. **Prepare the task spec**: Write a clear, self-contained task description with:
   - Objective (what needs to be done)
   - Context (relevant files, architecture constraints)
   - Acceptance criteria (how to know it's done)
   - Constraints (patterns to follow, patterns to avoid)

2. **Dispatch to Devin**: Pass the task spec as a Devin session
   - Include links to relevant files and documentation
   - Set the branch for Devin to work on
   - Define the expected deliverables

3. **Review output**: When Devin completes:
   - Review the PR/changes against the spec
   - Run the test suite
   - Check for architectural compliance
   - Request revisions if needed

## Best Practices

- Give Devin COMPLETE context — it works better with more information
- Set clear boundaries — tell it what NOT to change
- Use for tasks that are well-defined and self-contained
- Always review Devin's output before merging
- Pair with Copilot for iterative refinement after Devin's initial implementation

## Limitations

- Devin works best with well-defined tasks; ambiguous specs lead to wrong implementations
- Complex architectural changes should be designed by the Architect first
- Always validate Devin's security practices (input validation, auth, etc.)
