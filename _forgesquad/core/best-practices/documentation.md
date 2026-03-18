---
name: "Technical Documentation Standards"
---

# Technical Documentation Standards

## Document Types and Templates

| Type           | Purpose                                  | Audience          |
|----------------|------------------------------------------|-------------------|
| ADR            | Record architecture decisions            | Engineers         |
| Runbook        | Step-by-step incident response           | Ops / On-call     |
| API Doc        | Endpoint reference and examples          | API consumers     |
| Release Notes  | Summary of changes per version           | Stakeholders      |
| Design Doc     | Propose and discuss technical approaches | Engineering team  |

### ADR Template

```
# ADR-NNN: [Title]
- Status: Proposed | Accepted | Deprecated | Superseded
- Date: YYYY-MM-DD
- Context: What is the problem?
- Decision: What did we decide?
- Consequences: What are the trade-offs?
```

### Runbook Template

```
# Runbook: [Service/Incident Type]
- Severity: P1 | P2 | P3
- Symptoms: What does the alert look like?
- Diagnosis: Steps to identify root cause
- Resolution: Steps to fix
- Escalation: Who to contact if unresolved
```

## Writing Style Guidelines

- Use **active voice** and present tense.
- Write for the reader who has context but not your specific knowledge.
- Keep sentences under 25 words. One idea per paragraph.
- Define acronyms on first use.
- Use bullet points and tables over long paragraphs.
- Include code examples for any technical instruction.

## Diagram Standards

- Use the **C4 model** for architecture diagrams (Context, Container, Component, Code).
- Use **sequence diagrams** for API and service interactions.
- Use **ER diagrams** for data models.
- Author diagrams in code using Mermaid or PlantUML (version-controlled, diffable).
- Every diagram must have a title and a brief caption.

## Docs as Code Workflow

- Store documentation alongside source code in the repository.
- Write in Markdown; render with a static site generator (e.g., MkDocs, Docusaurus).
- Review docs in the same PR as code changes.
- Run linters (markdownlint, vale) in CI to enforce style.
- Publish automatically on merge to main.

## README Template

Every repository must include a README with:

```
# Project Name
One-line description.

## Getting Started
Prerequisites, install steps, run locally.

## Architecture
High-level overview and link to design docs.

## Contributing
Branch strategy, PR process, coding standards.

## Deployment
How to deploy and where it runs.

## Contact
Team name, Slack channel, on-call rotation.
```
