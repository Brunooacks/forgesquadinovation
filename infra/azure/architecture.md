# Arquitetura Azure para ForgeSquad / Azure Architecture for ForgeSquad

> **Versao:** 1.0 | **Data:** 2026-03-20 | **Status:** Production-Ready

---

## Visao Geral / Overview

ForgeSquad is a multi-agent orchestration framework for Software Engineering squads. This document describes how the framework's components map to Azure services for a production-grade deployment.

**ForgeSquad Numbers:**
- **9 Agents** (Architect, Tech Lead, BA, 2x Dev, QA, Tech Writer, PM, DevOps)
- **10 Phases** (Discovery through Production)
- **24 Pipeline Steps** (atomic units of work)
- **9 Human Checkpoints** (approval gates requiring stakeholder sign-off)

---

## Diagrama de Arquitetura / Architecture Diagram

```
                            Internet
                               |
                    +----------+----------+
                    |  Azure Front Door   |
                    |  + WAF Policy       |
                    +----------+----------+
                               |
                    +----------+----------+
                    | Azure AD B2C        |
                    | (OAuth: Google,     |
                    |  Microsoft, GitHub) |
                    +----------+----------+
                               |
              +----------------+----------------+
              |                                 |
   +----------+----------+          +-----------+-----------+
   | API Management      |          | Azure Static Web App  |
   | (Pipeline API)      |          | (Dashboard UI)        |
   +----------+----------+          +-----------------------+
              |
   +----------+----------+
   | Azure Functions      |
   | - pipeline-runner    |
   | - approval-gate      |
   | - artifact-validator |
   +----------+----------+
              |
   +----------+-------------------------------------------+
   |          |              |              |              |
   |  +-------+-------+  +--+--+  +-------+-------+      |
   |  | Container Apps |  | SB  |  | Event Grid    |      |
   |  | (9 Agents)     |  | Bus |  | (Notifications|      |
   |  | + Dapr         |  |     |  |  + Webhooks)  |      |
   |  +-------+-------+  +--+--+  +---------------+      |
   |          |              |                             |
   |  +-------+-------+  +--+------------+                |
   |  | Cosmos DB      |  | Blob Storage  |               |
   |  | (Audit Trail)  |  | (Artifacts)   |               |
   |  +---------------+  +---------------+                |
   |                                                      |
   |  +---------------+  +---------------+                |
   |  | Key Vault     |  | App Insights  |                |
   |  | (Secrets)     |  | + Log Analytics|               |
   |  +---------------+  +---------------+                |
   |                                                      |
   +------------------------------------------------------+
                    Virtual Network
                    10.0.0.0/16
```

---

## Mapeamento de Servicos / Service Mapping

| ForgeSquad Component | Azure Service | SKU/Tier | Purpose |
|---|---|---|---|
| Agent Runtime (9 agents) | Azure Container Apps | Consumption | Serverless container execution per agent persona |
| Pipeline Runner | Azure Functions (Durable) | Consumption | Orchestrates 24 steps across 10 phases |
| Approval Gates (9 checkpoints) | Azure Service Bus + Functions | Standard | Queue-based human approval workflow |
| Audit Trail | Azure Cosmos DB | Serverless | Append-only ledger with immutability policies |
| Artifact Storage | Azure Blob Storage | StorageV2 (Hot) | Versioned artifacts with SHA-256 integrity |
| API Gateway | Azure API Management | Developer/Standard | Rate limiting, auth, API versioning |
| Authentication | Azure AD B2C | Free/P1 | OAuth with Google, Microsoft, GitHub providers |
| Notifications | Azure Event Grid | Basic | Checkpoint events, webhook delivery |
| Agent Messaging | Dapr (via Container Apps) | Included | Pub/sub and service invocation between agents |
| Secrets Management | Azure Key Vault | Standard | API keys, connection strings, certificates |
| Monitoring | Application Insights + Log Analytics | Pay-as-you-go | Distributed tracing, metrics, alerts |
| CDN/WAF | Azure Front Door | Standard | Global load balancing, DDoS, WAF rules |
| DNS | Azure DNS | Standard | Custom domain management |

---

## Rede / Networking

### Virtual Network Layout

```
VNet: forgesquad-vnet (10.0.0.0/16)
|
+-- Subnet: snet-container-apps    10.0.1.0/23   (Container Apps Environment)
+-- Subnet: snet-functions         10.0.4.0/24   (Azure Functions VNet Integration)
+-- Subnet: snet-apim              10.0.5.0/24   (API Management)
+-- Subnet: snet-private-endpoints 10.0.6.0/24   (Private Link for Cosmos, Storage, KV)
+-- Subnet: snet-bastion           10.0.7.0/26   (Azure Bastion for ops access)
```

### Network Security Groups (NSGs)

| NSG | Subnet | Inbound Rules | Outbound Rules |
|---|---|---|---|
| nsg-container-apps | snet-container-apps | Deny all (Container Apps managed) | Allow HTTPS to private endpoints |
| nsg-functions | snet-functions | Deny all public | Allow to Service Bus, Cosmos, Storage |
| nsg-apim | snet-apim | Allow 443 from Front Door | Allow to Functions subnet |
| nsg-private-endpoints | snet-private-endpoints | Allow from VNet only | Deny all |

### Private Link Endpoints

All data services use Private Link to keep traffic within the VNet:
- Cosmos DB: `forgesquad-cosmos.privatelink.documents.azure.com`
- Blob Storage: `forgesquadartifacts.privatelink.blob.core.windows.net`
- Key Vault: `forgesquad-kv.privatelink.vaultcore.azure.net`
- Service Bus: `forgesquad-sb.privatelink.servicebus.windows.net`

---

## Seguranca / Security

### Identity & Access

- **Managed Identities**: Every compute resource (Functions, Container Apps) uses system-assigned managed identity
- **RBAC**: Least-privilege roles assigned per resource
  - Functions -> Cosmos DB: `Cosmos DB Data Contributor`
  - Functions -> Blob Storage: `Storage Blob Data Contributor`
  - Functions -> Key Vault: `Key Vault Secrets User`
  - Functions -> Service Bus: `Azure Service Bus Data Sender/Receiver`
  - Container Apps -> Key Vault: `Key Vault Secrets User`

### Encryption

- **At Rest**: All services use Microsoft-managed keys (CMK optional via Key Vault)
- **In Transit**: TLS 1.2+ enforced everywhere
- **Cosmos DB**: Immutability policy for audit trail (append-only, no deletes)
- **Blob Storage**: Immutable storage with version-level WORM for signed artifacts

### WAF Rules (Front Door)

- OWASP 3.2 Core Rule Set
- Rate limiting: 1000 req/min per IP
- Bot protection: Enabled
- Geo-filtering: Configurable per tenant

---

## Estimativa de Custos / Cost Estimation

### Development Tier (1 developer, low traffic)

| Service | Monthly Cost (USD) |
|---|---|
| Container Apps (Consumption) | ~$5 (idle most of time) |
| Azure Functions (Consumption) | ~$0 (free tier: 1M executions) |
| Cosmos DB (Serverless) | ~$5 (low RU consumption) |
| Blob Storage (Hot, <10 GB) | ~$2 |
| Service Bus (Standard) | ~$10 |
| API Management (Developer) | ~$48 |
| Key Vault | ~$1 |
| Application Insights | ~$3 |
| Azure AD B2C (Free tier) | $0 |
| **Total** | **~$74/month** |

### Staging Tier (5 users, moderate traffic)

| Service | Monthly Cost (USD) |
|---|---|
| Container Apps | ~$30 |
| Azure Functions | ~$5 |
| Cosmos DB (Serverless) | ~$20 |
| Blob Storage (<50 GB) | ~$10 |
| Service Bus (Standard) | ~$10 |
| API Management (Standard) | ~$280 |
| Front Door (Standard) | ~$35 |
| Key Vault | ~$3 |
| Application Insights | ~$15 |
| Azure AD B2C (P1) | ~$28 |
| **Total** | **~$436/month** |

### Production Tier (50+ users, high traffic)

| Service | Monthly Cost (USD) |
|---|---|
| Container Apps (dedicated) | ~$150 |
| Azure Functions (EP1) | ~$120 |
| Cosmos DB (Autoscale 4000 RU) | ~$190 |
| Blob Storage (<500 GB) | ~$50 |
| Service Bus (Premium) | ~$668 |
| API Management (Standard) | ~$280 |
| Front Door (Premium + WAF) | ~$165 |
| Key Vault | ~$10 |
| Application Insights | ~$50 |
| Azure AD B2C (P2) | ~$56 |
| Log Analytics | ~$45 |
| Private Link endpoints (5x) | ~$50 |
| **Total** | **~$1,834/month** |

---

## Comparacao com AWS / Comparison with AWS

| Capability | Azure (this architecture) | AWS Equivalent |
|---|---|---|
| Container Runtime | Azure Container Apps + Dapr | ECS Fargate + App Mesh |
| Orchestration | Durable Functions | Step Functions |
| API Gateway | API Management | API Gateway |
| Message Queue | Service Bus | SQS + SNS |
| Event Routing | Event Grid | EventBridge |
| Document DB | Cosmos DB (Serverless) | DynamoDB (On-Demand) |
| Object Storage | Blob Storage | S3 |
| Auth | Azure AD B2C | Cognito |
| Secrets | Key Vault | Secrets Manager |
| CDN/WAF | Front Door + WAF | CloudFront + WAF |
| Monitoring | App Insights + Log Analytics | CloudWatch + X-Ray |
| IaC | Bicep / ARM | CloudFormation / CDK |

### Diferenciais Azure / Azure Advantages

1. **Dapr Integration**: Native Dapr support in Container Apps provides built-in pub/sub, service invocation, and state management without extra infrastructure
2. **Durable Functions**: Superior orchestration model with built-in checkpointing, retry, and fan-out/fan-in patterns -- ideal for ForgeSquad's 24-step pipeline
3. **Cosmos DB Immutability**: Native immutability policies for audit trail compliance
4. **Microsoft 365 Integration**: Native integration with Teams (checkpoint notifications), Outlook (email alerts), and Azure DevOps (CI/CD pipelines)
5. **Azure AD B2C**: Simpler OAuth configuration with Microsoft corporate accounts
6. **Private Link Ecosystem**: Comprehensive Private Link support across all services
7. **Cost Optimization**: Container Apps consumption plan + Functions consumption plan = near-zero idle cost

### Diferenciais AWS / AWS Advantages

1. **Step Functions**: Visual workflow designer and broader state machine features
2. **Lambda Ecosystem**: Larger marketplace of pre-built integrations
3. **S3 Maturity**: More advanced lifecycle policies and storage classes
4. **Global Footprint**: More regions available worldwide

---

## Proximos Passos / Next Steps

1. Deploy using `scripts/deploy.sh` or Bicep directly
2. Configure Azure AD B2C tenant and identity providers
3. Build and push agent container images to Azure Container Registry
4. Configure Dapr components for Service Bus pub/sub
5. Set up Azure DevOps or GitHub Actions for CI/CD
6. Configure Application Insights dashboards and alerts
7. Enable Private Link endpoints for production
