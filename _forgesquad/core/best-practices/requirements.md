---
name: "Requirements Engineering"
---

# Requirements Engineering

## User Story Format

Use the standard format to capture intent and value:

```
As a [role],
I want [capability],
So that [business value].
```

Guidelines:
- Keep stories small enough to complete in a single sprint.
- Each story delivers a **vertical slice** of functionality.
- Write from the user's perspective, not the system's.
- Include the "So that" clause -- it clarifies priority and enables trade-offs.

## Acceptance Criteria Format (Given/When/Then)

```
Given [precondition],
When [action],
Then [expected outcome].
```

Example:
```
Given a registered user with a valid session,
When they submit an order with items in the cart,
Then the order is created with status "pending"
  and the user receives a confirmation email within 5 minutes.
```

- Write 3-7 acceptance criteria per story.
- Cover the happy path, at least one error path, and boundary conditions.
- Acceptance criteria are testable -- if you cannot automate it, rewrite it.

## Definition of Ready Checklist

A story is ready for development when:

- [ ] User story follows the standard format.
- [ ] Acceptance criteria are written and reviewed by the team.
- [ ] Dependencies are identified and resolved (APIs, data, third-party services).
- [ ] UX/UI designs are attached (if applicable).
- [ ] Story is estimated by the team.
- [ ] Non-functional requirements are specified (performance, security, accessibility).
- [ ] No open questions or ambiguities remain.

## Non-Functional Requirements Template

Capture NFRs explicitly for each feature or service:

| Category        | Requirement                                       |
|-----------------|---------------------------------------------------|
| Performance     | API response time < 300 ms at p95                 |
| Availability    | 99.9% uptime (monthly)                            |
| Scalability     | Support 10,000 concurrent users                   |
| Security        | All data encrypted in transit (TLS 1.2+)          |
| Accessibility   | WCAG 2.1 AA compliance                            |
| Compatibility   | Support latest 2 versions of Chrome, Firefox, Edge|
| Data Retention  | Retain user data for 7 years per regulation       |

## Requirements Traceability

- Assign a unique ID to every requirement (e.g., `REQ-USR-042`).
- Link requirements to user stories, test cases, and design docs.
- Maintain a traceability matrix updated each sprint.
- When a requirement changes, update all linked artifacts.
- Use labels or tags in the issue tracker to maintain traceability at scale.
