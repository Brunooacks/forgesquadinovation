---
name: "GitHub Copilot"
description: "AI pair programmer for inline code suggestions and completions"
type: tool
version: "1.0.0"
category: development
agents: [dev-backend, dev-frontend, qa-engineer, tech-lead]
---

# GitHub Copilot — AI Pair Programmer

Copilot provides real-time code suggestions, completions, and pair programming assistance.

## When to Use Copilot

- **Inline completions**: Code suggestions as you type
- **Code generation**: Generate functions, classes, tests from comments/prompts
- **Code explanation**: Understand existing code with Copilot Chat
- **Refactoring assistance**: Improve code quality with suggestions
- **Test writing**: Generate test cases from implementation code

## Integration Pattern

When a squad agent works with Copilot:

1. **Context setup**: Ensure relevant files are open for Copilot context
2. **Comment-driven development**: Write clear comments/docstrings describing intent
3. **Iterative refinement**: Accept, modify, or reject suggestions
4. **Copilot Chat**: Use for complex questions, explanations, and multi-file changes

## Best Practices

- Write clear comments before asking for completions
- Review every suggestion — Copilot can hallucinate APIs or patterns
- Use Copilot Chat for architectural questions and explanations
- Combine with manual coding for critical security/auth logic
- Use workspace references (@workspace) for project-aware suggestions

## Agent-Specific Usage

- **Dev Backend**: API implementation, database queries, middleware
- **Dev Frontend**: Component creation, state management, API integration
- **QA Engineer**: Test case generation, assertion patterns, mock setup
- **Tech Lead**: Code review assistance, pattern detection, refactoring suggestions
