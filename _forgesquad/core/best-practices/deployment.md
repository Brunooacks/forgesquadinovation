---
name: "Deployment & CI/CD"
---

# Deployment & CI/CD

## CI/CD Pipeline Stages

Every pipeline should include these stages in order:

1. **Build** -- Compile code, resolve dependencies, produce artifacts.
2. **Lint & Format** -- Enforce code style and static analysis rules.
3. **Unit Tests** -- Run fast, isolated tests. Fail fast on regressions.
4. **Security Scan** -- SAST, dependency vulnerability check, secrets detection.
5. **Integration Tests** -- Verify component interactions.
6. **Package** -- Build container image or deployment artifact. Tag with commit SHA.
7. **Deploy to Staging** -- Automatic deployment to staging environment.
8. **E2E / Smoke Tests** -- Validate critical paths on staging.
9. **Deploy to Production** -- Manual approval gate, then automated deployment.

## Environment Strategy

| Environment | Purpose                        | Data              | Access         |
|-------------|--------------------------------|-------------------|----------------|
| Dev         | Developer experimentation      | Synthetic/seed    | Engineers      |
| Staging     | Pre-production validation      | Anonymized prod   | Engineering+QA |
| Production  | Live user traffic              | Real              | Restricted     |

- Staging must mirror production configuration as closely as possible.
- Never use production data in dev without anonymization.

## Deployment Strategies

### Blue/Green
- Maintain two identical environments (blue and green).
- Deploy new version to inactive environment, run smoke tests.
- Switch traffic via load balancer. Keep old environment warm for instant rollback.

### Canary
- Route a small percentage of traffic (5-10%) to the new version.
- Monitor error rates, latency, and business metrics.
- Gradually increase traffic if metrics are healthy. Roll back if not.

Choose **blue/green** for simplicity and instant rollback. Choose **canary** when gradual validation is needed.

## Rollback Strategy

- Every deployment must be reversible within **5 minutes**.
- Use immutable artifacts -- never patch in place.
- Database migrations must be backward-compatible (expand/contract pattern).
- Automate rollback triggers based on error rate or latency thresholds.
- Document rollback steps in the service runbook.

## Feature Flags

- Use feature flags to decouple deployment from release.
- Flag naming convention: `ff.[team].[feature]` (e.g., `ff.payments.new-checkout`).
- Clean up flags within **2 sprints** after full rollout.
- Avoid nesting flags -- it creates combinatorial complexity.
- Maintain a registry of active flags with owners and expiry dates.

## Deployment Checklist

Before deploying to production:

- [ ] All CI stages green.
- [ ] Staging smoke tests passed.
- [ ] Database migrations tested and backward-compatible.
- [ ] Feature flags configured for gradual rollout.
- [ ] Rollback plan documented and tested.
- [ ] On-call engineer notified.
- [ ] Monitoring dashboards reviewed for baseline.
