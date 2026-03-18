---
name: "Kiro"
description: "AI-powered requirements and specifications tool"
type: tool
version: "1.0.0"
category: requirements
agents: [business-analyst, architect]
---

# Kiro — Requirements & Specifications Tool

Kiro is an AI-powered tool for generating and refining software requirements, specifications, and user stories.

## When to Use Kiro

- **Requirements generation**: Generate user stories from high-level descriptions
- **Spec refinement**: Refine and detail specifications iteratively
- **Acceptance criteria**: Generate Given/When/Then acceptance criteria
- **Task breakdown**: Break epics into stories and stories into tasks
- **Requirements validation**: Check completeness and consistency

## Integration Pattern

When the Business Analyst works with Kiro:

1. **Input project context**: Provide project description, goals, and constraints
2. **Generate initial specs**: Use Kiro to create first draft of requirements
3. **Refine iteratively**: Review, adjust, and add detail through conversation
4. **Export structured output**: Generate user stories in standard format
5. **Validate with stakeholders**: Present Kiro-generated specs for approval

## Best Practices

- Start with high-level goals before diving into details
- Use Kiro's structured output format for consistency
- Always have the BA review and refine Kiro's output — AI-generated specs need human judgment
- Feed Kiro existing documentation for context-aware generation
- Use Kiro to identify gaps in requirements — missing edge cases, error scenarios

## Output Formats

- **User Stories**: As a [role], I want [feature], so that [benefit]
- **Acceptance Criteria**: Given [context], When [action], Then [result]
- **Task Breakdown**: Hierarchical list of implementation tasks with estimates
- **Requirements Matrix**: Traceability matrix linking requirements to features
