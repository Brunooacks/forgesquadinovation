# Arquitetura AWS — ForgeSquad Multi-Agent Orchestration

> AWS Architecture Guide for deploying ForgeSquad in production.
> Bilingual: Portuguese section titles, English technical content.

---

## Visao Geral / Overview

ForgeSquad is a multi-agent orchestration framework for software engineering squads.
It comprises **9 agents**, **10 phases**, **24 pipeline steps**, and **9 human checkpoints**.

This document describes the complete AWS architecture that supports:

- Agent execution at scale (ECS Fargate)
- Pipeline orchestration (Lambda + Step Functions)
- Human-in-the-loop approvals (SQS + API Gateway)
- Immutable audit trail (DynamoDB append-only)
- Artifact storage with integrity verification (S3 + SHA-256)
- Authentication and authorization (Cognito + IAM)
- Monitoring and alerting (CloudWatch + SNS)

---

## Diagrama de Arquitetura / Architecture Diagram

```
                          +---------------------------+
                          |     Amazon CloudFront     |
                          |   (CDN + WAF Protection)  |
                          +------------+--------------+
                                       |
                          +------------v--------------+
                          |     API Gateway (REST)    |
                          |   /pipeline  /approval    |
                          |   /agents    /reports     |
                          +---+-------+-------+-------+
                              |       |       |
              +---------------+   +---+---+   +---------------+
              |                   |       |                   |
    +---------v--------+  +------v----+  +v---------+  +-----v--------+
    | Lambda:          |  | Lambda:   |  | Lambda:  |  | Lambda:      |
    | pipeline-runner  |  | approval- |  | report-  |  | webhook-     |
    |                  |  | gate      |  | generator|  | handler      |
    +--------+---------+  +-----+-----+  +----+-----+  +------+-------+
             |                  |              |               |
             |   +--------------+--------------+---------------+
             |   |
    +--------v---v---------+        +-------------------------+
    |  Amazon SQS Queues   |        |  Amazon SNS Topics      |
    |                      |        |                         |
    | - agent-dispatch     |        | - checkpoint-notify     |
    | - approval-requests  |        | - pipeline-complete     |
    | - agent-responses    |        | - error-alerts          |
    | - dead-letter        |        +------------+------------+
    +--------+-------------+                     |
             |                          Email / Slack / Teams
    +--------v-----------------+
    |   Amazon ECS Fargate     |
    |   Cluster: forgesquad    |
    |                          |
    |  +----+ +----+ +----+    |     +-------------------------+
    |  | A1 | | A2 | | A3 |   |     |   Amazon DynamoDB       |
    |  +----+ +----+ +----+    |     |                         |
    |  +----+ +----+ +----+    |     | - audit-trail (append)  |
    |  | A4 | | A5 | | A6 |   +---->| - pipeline-state        |
    |  +----+ +----+ +----+    |     | - agent-sessions        |
    |  +----+ +----+ +----+    |     | - checkpoints           |
    |  | A7 | | A8 | | A9 |   |     +-------------------------+
    |  +----+ +----+ +----+    |
    +-----------+--------------+     +-------------------------+
                |                    |   Amazon S3             |
                +------------------->|                         |
                                     | - artifacts bucket     |
                                     |   (versioning + SHA)   |
                                     | - reports bucket       |
                                     | - agent-configs        |
                                     +-------------------------+

    +----------------------------------------------------------+
    |                    Security Layer                         |
    |                                                          |
    |  +-------------+  +----------+  +---------------------+  |
    |  | Cognito     |  | KMS      |  | Secrets Manager     |  |
    |  | User Pool   |  | Keys     |  | API Keys / Tokens   |  |
    |  | + Identity  |  | (AES-256)|  | (Devin, Copilot,    |  |
    |  |   Pool      |  |          |  |  GitHub, StackSpot)  | |
    |  +-------------+  +----------+  +---------------------+  |
    +----------------------------------------------------------+

    +----------------------------------------------------------+
    |                  Observability Layer                      |
    |                                                          |
    |  +----------------+  +--------------+  +---------------+ |
    |  | CloudWatch     |  | CloudWatch   |  | X-Ray         | |
    |  | Logs           |  | Metrics +    |  | Distributed   | |
    |  | (all services) |  | Dashboards   |  | Tracing       | |
    |  +----------------+  +--------------+  +---------------+ |
    +----------------------------------------------------------+
```

**Legend:** A1-A9 = ForgeSquad Agents (Architect, Tech Lead, BA, Dev-Backend, Dev-Frontend, Dev-CLI, QA, Tech Writer, PM)

---

## Mapeamento de Servicos / Service Mapping

| ForgeSquad Component | AWS Service | Purpose |
|---|---|---|
| Agent Runtime | ECS Fargate | Runs each agent as a container task |
| Pipeline Runner | Lambda + Step Functions | Orchestrates the 24-step pipeline |
| Agent Communication | SQS | Decoupled message passing between agents |
| Human Checkpoints | SQS + API Gateway + Lambda | Pause pipeline, notify, wait for approval |
| Checkpoint Notifications | SNS | Email/Slack/Teams alerts at 9 checkpoints |
| Audit Trail | DynamoDB (append-only) | Immutable log of all pipeline events |
| Pipeline State | DynamoDB | Current state of each pipeline execution |
| Artifact Storage | S3 (versioned) | Code, docs, reports with SHA-256 checksums |
| Authentication | Cognito | OAuth via Google, Microsoft, GitHub |
| Authorization | IAM + Cognito Groups | Role-based access to API endpoints |
| API Layer | API Gateway + CloudFront | REST API with CDN caching and WAF |
| Secrets | Secrets Manager | API keys for Devin, Copilot, StackSpot, GitHub |
| Encryption | KMS | AES-256 encryption at rest for all services |
| Monitoring | CloudWatch + X-Ray | Logs, metrics, dashboards, distributed tracing |
| WAF | AWS WAF | Rate limiting, IP filtering, SQL injection protection |

---

## Fases e Checkpoints / Phases and Checkpoints

| Phase | Steps | Checkpoint? | Agent(s) |
|---|---|---|---|
| 1. Requirements | 1-3 | YES - Requirements approval | BA, Architect |
| 2. Architecture | 4-5 | YES - Architecture review | Architect |
| 3. Planning | 6-7 | YES - Sprint plan approval | Tech Lead, PM |
| 4. Backend Dev | 8-10 | YES - Backend PR review | Dev-Backend, Architect |
| 5. Frontend Dev | 11-13 | YES - Frontend PR review | Dev-Frontend, Architect |
| 6. CLI Dev | 14-15 | NO | Dev-CLI |
| 7. Integration | 16-17 | YES - Integration approval | Tech Lead, Architect |
| 8. QA | 18-20 | YES - QA sign-off | QA Engineer |
| 9. Documentation | 21-23 | YES - Docs review | Tech Writer |
| 10. Release | 24 | YES - Go/No-Go | PM, Architect |

---

## Rede / Networking

### VPC Design

```
VPC: 10.0.0.0/16 (65,536 IPs)

  Public Subnets (internet-facing):
    10.0.1.0/24  — AZ-a  (NAT Gateway, ALB)
    10.0.2.0/24  — AZ-b  (NAT Gateway, ALB)

  Private Subnets (application):
    10.0.10.0/24 — AZ-a  (ECS Fargate tasks)
    10.0.11.0/24 — AZ-b  (ECS Fargate tasks)

  Isolated Subnets (data):
    10.0.20.0/24 — AZ-a  (VPC Endpoints only)
    10.0.21.0/24 — AZ-b  (VPC Endpoints only)
```

### Security Groups

| Security Group | Inbound | Outbound | Used By |
|---|---|---|---|
| sg-alb | 443 from 0.0.0.0/0 | All to sg-ecs | API Gateway VPC Link |
| sg-ecs | All from sg-alb | 443 to 0.0.0.0/0 | ECS Fargate tasks |
| sg-vpc-endpoints | 443 from sg-ecs | None | DynamoDB, S3, SQS, SNS endpoints |

### VPC Endpoints (PrivateLink)

All AWS service communication stays within the VPC via endpoints:
- `com.amazonaws.{region}.s3` (Gateway)
- `com.amazonaws.{region}.dynamodb` (Gateway)
- `com.amazonaws.{region}.sqs` (Interface)
- `com.amazonaws.{region}.sns` (Interface)
- `com.amazonaws.{region}.secretsmanager` (Interface)
- `com.amazonaws.{region}.kms` (Interface)
- `com.amazonaws.{region}.logs` (Interface)
- `com.amazonaws.{region}.ecr.dkr` (Interface)
- `com.amazonaws.{region}.ecr.api` (Interface)

---

## Modelo de Custos / Cost Estimation

### Tier: Development

| Service | Configuration | Monthly Cost (USD) |
|---|---|---|
| ECS Fargate | 0.25 vCPU / 0.5 GB, ~50 task-hours/month | $2.50 |
| Lambda | ~10,000 invocations, 256 MB | $0.10 |
| API Gateway | ~10,000 requests | $0.04 |
| DynamoDB | On-demand, ~1 GB storage | $1.25 |
| S3 | 5 GB storage, 1,000 requests | $0.15 |
| SQS | ~50,000 messages | $0.02 |
| SNS | ~1,000 notifications | $0.01 |
| CloudWatch | Basic metrics + 5 GB logs | $2.50 |
| Cognito | <50 MAU (free tier) | $0.00 |
| KMS | 1 key, ~1,000 requests | $1.03 |
| NAT Gateway | 1 instance, minimal data | $32.40 |
| **Total** | | **~$40/month** |

### Tier: Staging

| Service | Configuration | Monthly Cost (USD) |
|---|---|---|
| ECS Fargate | 0.5 vCPU / 1 GB, ~500 task-hours/month | $25.00 |
| Lambda | ~100,000 invocations, 512 MB | $1.00 |
| API Gateway | ~100,000 requests | $0.35 |
| DynamoDB | On-demand, ~10 GB storage | $2.50 |
| S3 | 50 GB storage, 10,000 requests | $1.20 |
| SQS | ~500,000 messages | $0.20 |
| SNS | ~10,000 notifications | $0.10 |
| CloudWatch | Detailed metrics + 20 GB logs | $10.00 |
| Cognito | <500 MAU | $0.00 |
| KMS | 2 keys, ~10,000 requests | $2.03 |
| NAT Gateway | 2 instances (HA) | $64.80 |
| WAF | Basic rules | $6.00 |
| **Total** | | **~$113/month** |

### Tier: Production

| Service | Configuration | Monthly Cost (USD) |
|---|---|---|
| ECS Fargate | 1 vCPU / 2 GB, ~5,000 task-hours/month | $250.00 |
| Lambda | ~1,000,000 invocations, 1024 MB | $10.00 |
| API Gateway | ~1,000,000 requests | $3.50 |
| DynamoDB | Provisioned (25 RCU/WCU), ~100 GB | $25.00 |
| S3 | 500 GB storage, 100,000 requests | $12.00 |
| SQS | ~5,000,000 messages | $2.00 |
| SNS | ~100,000 notifications | $1.00 |
| CloudWatch | Detailed metrics + 100 GB logs + dashboards | $50.00 |
| Cognito | ~5,000 MAU | $27.75 |
| KMS | 3 keys, ~100,000 requests | $3.09 |
| NAT Gateway | 2 instances (HA), 100 GB data | $73.80 |
| WAF | Full rule set + Bot Control | $16.00 |
| CloudFront | 100 GB transfer | $8.50 |
| X-Ray | ~1M traces | $5.00 |
| Secrets Manager | 10 secrets | $4.00 |
| **Total** | | **~$492/month** |

> Note: Costs are estimates based on us-east-1 pricing as of 2026. Actual costs vary with usage.

---

## Seguranca / Security Best Practices

1. **Encryption at Rest** — All data encrypted via KMS (AES-256): DynamoDB, S3, SQS, SNS, CloudWatch Logs, ECS ephemeral storage.
2. **Encryption in Transit** — TLS 1.2+ enforced on all endpoints. S3 bucket policy denies non-HTTPS requests.
3. **Least Privilege IAM** — Each Lambda and ECS task has a dedicated IAM role with only the permissions it needs.
4. **Network Isolation** — ECS tasks run in private subnets. No public IPs. All AWS service access via VPC Endpoints.
5. **WAF Protection** — Rate limiting (1,000 req/5min per IP), SQL injection rules, XSS protection, geographic restrictions.
6. **Audit Trail** — DynamoDB audit table is append-only (IAM policy denies UpdateItem/DeleteItem). Point-in-time recovery enabled.
7. **Secrets Rotation** — All API keys stored in Secrets Manager with automatic rotation every 30 days.
8. **Cognito MFA** — Multi-factor authentication required for production access.
9. **S3 Integrity** — All artifacts stored with SHA-256 checksums. Bucket versioning enabled. MFA Delete for production.

---

## Disponibilidade e Resiliencia / Availability and Resilience

- **Multi-AZ** — All services deployed across 2 availability zones minimum.
- **Auto-scaling** — ECS Fargate auto-scales based on SQS queue depth. DynamoDB uses on-demand capacity.
- **Dead Letter Queues** — All SQS queues have DLQs for failed messages (max 3 retries).
- **Circuit Breakers** — Lambda functions implement circuit breaker pattern for external API calls (Devin, Copilot, StackSpot).
- **Backup** — DynamoDB point-in-time recovery (35 days). S3 cross-region replication for production.
- **RTO/RPO** — Recovery Time Objective: 15 minutes. Recovery Point Objective: 1 hour.
