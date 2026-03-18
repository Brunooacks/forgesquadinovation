---
name: "Code Review Guidelines"
---

# Code Review Guidelines

## PR Size Guidelines

- Target **under 400 lines** of changed code per PR.
- Large changes should be split into stacked or sequential PRs.
- If a PR exceeds 400 lines, add a summary explaining why the split was not feasible.
- Refactoring PRs should be separate from feature PRs.

## Review Checklist

Every reviewer should evaluate these dimensions:

1. **Correctness** -- Does the code do what it claims? Are edge cases handled?
2. **Security** -- No hardcoded secrets, proper input validation, authorization checks.
3. **Performance** -- No N+1 queries, unnecessary allocations, or blocking calls on hot paths.
4. **Readability** -- Clear naming, small functions, no premature abstraction.
5. **Tests** -- New or changed behavior is covered by tests. Tests are deterministic.
6. **Documentation** -- Public APIs and non-obvious logic are documented.

## How to Give Constructive Feedback

- Comment on the **code**, not the person.
- Use questions to guide: "Have you considered...?" rather than "This is wrong."
- Prefix comments with intent:
  - `nit:` -- Minor style issue, optional to fix.
  - `suggestion:` -- Improvement idea, not blocking.
  - `blocker:` -- Must be resolved before merge.
- Acknowledge good work: "Nice approach here."

## Approval Criteria

- At least **one approval** from a code owner or senior engineer.
- Zero unresolved `blocker:` comments.
- All CI checks passing (build, lint, tests, security scan).
- No merge conflicts with the target branch.
- PR description explains the **what** and **why**.

## Common Red Flags

- Functions longer than 50 lines.
- Deeply nested conditionals (more than 3 levels).
- Copy-pasted code instead of shared abstractions.
- Catching generic exceptions without logging or re-throwing.
- TODO comments without a linked ticket.
- Magic numbers or strings without named constants.
- Missing error handling on external calls (HTTP, DB, file I/O).
- Tests that depend on execution order or external state.

## Response Time Expectations

- First review within **4 business hours** of PR submission.
- Follow-up responses within **2 business hours**.
- If you cannot review in time, reassign or notify the author.
