---
name: "DevOps Engineering"
description: "CI/CD pipelines, infrastructure as code, container orchestration, GitOps, deployment strategies"
type: prompt
version: "1.0.0"
category: operations
agents: [architect, dev-backend, tech-lead]
---

# DevOps Engineering — Infrastructure & Delivery Skill

Provides DevOps engineering knowledge for building reliable CI/CD pipelines, managing infrastructure as code, and implementing modern deployment strategies.

## When to Use DevOps

- **CI/CD setup**: Pipeline design, stage definitions, artifact management
- **Infrastructure**: IaC patterns, cloud provisioning, environment management
- **Containers**: Docker, Kubernetes, Helm, container security
- **Deployments**: Blue/green, canary, rolling, feature flags
- **GitOps**: Repository structure, ArgoCD/Flux, environment promotion

## CI/CD Pipeline Design

### Standard Pipeline Stages
```
┌─────────┐    ┌──────┐    ┌──────┐    ┌──────────┐    ┌────────┐    ┌────────┐
│  Build   │───▶│ Test │───▶│ Lint │───▶│ Security │───▶│ Deploy │───▶│ Verify │
└─────────┘    └──────┘    └──────┘    └──────────┘    └────────┘    └────────┘
```

### Stage Details

**Build**:
- Compile/transpile source code
- Generate artifacts (Docker images, binaries, packages)
- Tag with git SHA + semantic version
- Cache dependencies (node_modules, .m2, pip cache)

**Test**:
- Unit tests (parallel execution, fail fast)
- Integration tests (with test databases/services)
- Coverage report (enforce minimum thresholds)
- Test result artifacts for later review

**Lint & Format**:
- Language-specific linting (ESLint, Pylint, golangci-lint)
- Code formatting check (Prettier, Black, gofmt)
- Commit message validation (conventional commits)

**Security Scan**:
- SAST: Static analysis (Semgrep, SonarQube, CodeQL)
- Dependency scan: Known vulnerabilities (Snyk, Trivy, Dependabot)
- Container scan: Image vulnerabilities (Trivy, Grype)
- Secret detection: Hardcoded credentials (Gitleaks, TruffleHog)
- **Block on**: Critical/High severity findings

**Deploy**:
- Environment-specific configuration
- Database migrations (run before deploy)
- Rolling/blue-green/canary based on environment
- Smoke tests post-deploy

**Verify**:
- Health check endpoints
- Synthetic monitoring
- Performance baseline comparison
- Rollback trigger if verification fails

### Pipeline Best Practices
- **Fail fast**: Run quick checks (lint, compile) before slow ones (integration tests)
- **Parallelize**: Run independent stages concurrently
- **Cache aggressively**: Dependencies, Docker layers, test databases
- **Artifact once, deploy many**: Build once, promote through environments
- **Immutable artifacts**: Never modify a built artifact — rebuild if needed

## Infrastructure as Code

### Terraform Patterns

**Module Structure**:
```
infra/
├── modules/
│   ├── networking/       # VPC, subnets, security groups
│   ├── compute/          # ECS/EKS/EC2 definitions
│   ├── database/         # RDS/DynamoDB/CosmosDB
│   ├── monitoring/       # CloudWatch/Prometheus/Grafana
│   └── security/         # IAM, KMS, WAF
├── environments/
│   ├── dev/
│   │   ├── main.tf       # Module composition
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── prod/
└── shared/
    ├── backend.tf         # Remote state configuration
    └── providers.tf       # Provider versions
```

**State Management**:
- Remote state: S3 + DynamoDB lock (AWS) or Blob Storage + CosmosDB (Azure)
- State per environment (never share state across environments)
- State locking mandatory (prevent concurrent modifications)
- Regular state backup and drift detection

**PR-Based Infrastructure Changes**:
1. `terraform plan` on PR creation → post plan as PR comment
2. Mandatory human review of plan
3. `terraform apply` only after PR approval
4. Tag applied commit with environment/version

### Drift Detection
- Schedule weekly `terraform plan` runs
- Alert if drift detected (manual console changes)
- Auto-remediate non-critical drift, escalate critical changes

## Container Orchestration

### Dockerfile Best Practices
```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --production=false
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -s /bin/sh -D appuser
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/server.js"]
```

### Kubernetes Manifests

**Resource Limits** (always set):
```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

**Health Checks** (always configure):
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 15
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

**HPA (Horizontal Pod Autoscaler)**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### Helm Chart Structure
```
charts/{service-name}/
├── Chart.yaml
├── values.yaml            # Default values
├── values-dev.yaml        # Dev overrides
├── values-staging.yaml    # Staging overrides
├── values-prod.yaml       # Production overrides
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── hpa.yaml
    ├── configmap.yaml
    └── secrets.yaml       # ExternalSecret references
```

## GitOps

### Repository Structure
```
gitops-repo/
├── apps/                  # Application manifests
│   ├── service-a/
│   │   ├── base/         # Kustomize base
│   │   └── overlays/
│   │       ├── dev/
│   │       ├── staging/
│   │       └── prod/
│   └── service-b/
├── infra/                 # Cluster-level resources
│   ├── namespaces/
│   ├── monitoring/
│   └── security/
└── argocd/               # ArgoCD Application definitions
    ├── dev.yaml
    ├── staging.yaml
    └── prod.yaml
```

### Environment Promotion Flow
```
Dev (auto-deploy on merge) → Staging (auto-deploy, run E2E) → Prod (manual approval, canary)
```

### Sealed Secrets
- Never commit plain secrets to git
- Use: SealedSecrets (Bitnami), ExternalSecrets (with Vault/AWS SM), or SOPS

## Deployment Strategies

### Blue/Green
```
┌────────────┐     ┌────────────┐
│   Blue     │     │   Green    │
│  (current) │     │   (new)    │
└─────┬──────┘     └─────┬──────┘
      │                   │
      └───── Router ──────┘
              │
         Switch traffic
         100% at once
```
- **Use when**: Zero-downtime required, easy rollback needed
- **Rollback**: Switch router back to blue (instant)
- **Cost**: 2x infrastructure during deployment

### Canary
```
Traffic split: 95% → Current | 5% → Canary
Monitor metrics for 15 minutes
If healthy: increase to 25% → 50% → 100%
If unhealthy: rollback to 0%
```
- **Use when**: Gradual validation needed, risk mitigation
- **Metrics to watch**: Error rate, latency, business metrics
- **Rollback**: Stop canary, route all traffic to stable

### Rolling Update
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 25%        # Extra pods during update
    maxUnavailable: 0    # Always maintain full capacity
```
- **Use when**: Standard deployments, stateless services
- **Rollback**: `kubectl rollout undo` (automatic with failed health checks)

### Feature Flags
- Decouple deployment from release
- Ship code dark, enable per-user/percentage/region
- Tools: LaunchDarkly, Unleash, Flagsmith, or custom
- Clean up flags within 2 sprints of full rollout

## Environment Management

### Parity Principle
- Dev/staging/prod should be as similar as possible
- Same Docker images, same configs (different values)
- Same database engine (just different size/replicas)
- Staging mirrors production data structure (anonymized)

### Ephemeral Environments
- Spin up per-PR preview environments
- Auto-destroy after PR merge/close
- Use for QA review and stakeholder demos
- Keep costs low: smaller instances, shorter TTL

### Secret Management
```
Production secrets:
├── Application secrets → HashiCorp Vault / AWS Secrets Manager / Azure Key Vault
├── Database credentials → Rotated automatically every 90 days
├── API keys → Scoped to minimum permissions
└── TLS certificates → Auto-renewed (cert-manager / ACM)
```

### Database Migration Strategy
- Migrations are forward-only and version-controlled
- Every migration must be reversible (up + down)
- Run migrations BEFORE deploying new code
- Separate migration job from application deployment
- Test migrations against production-sized dataset in staging

## Limitations

- DevOps practices should match team maturity — don't over-engineer for small teams
- GitOps requires discipline in repository management and review processes
- Canary deployments need sufficient traffic to be statistically meaningful
- Infrastructure as Code has a learning curve — invest in team training
