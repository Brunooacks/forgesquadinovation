---
name: "SonarQube"
description: "Code quality and security analysis platform"
type: integration
version: "1.0.0"
category: quality
agents: [qa-engineer, tech-lead, architect]
---

# SonarQube — Code Quality & Security Analysis

Integrates static code analysis for quality gates and security vulnerability detection.

## When to Use

- **Quality gate**: Run before code review to catch issues early
- **Security scan**: SAST analysis for vulnerability detection
- **Tech debt tracking**: Monitor and manage technical debt
- **Coverage reports**: Track test coverage metrics

## Integration Pattern

1. **Pre-review scan**: Run SonarQube analysis after implementation steps
2. **Quality gate check**: Verify quality gate passes before code review
3. **Report to PM**: Include SonarQube metrics in status reports
4. **Block on critical**: Fail pipeline if critical vulnerabilities found

## Quality Gate Criteria

- No new critical/blocker issues
- Test coverage >= 80% on new code
- Duplicated lines <= 3%
- Maintainability rating A
- No new security hotspots unreviewed
