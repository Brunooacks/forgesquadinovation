# Guia de Setup — ForgeSquad na AWS

> Step-by-step deployment guide for ForgeSquad on AWS.
> Bilingual: Portuguese section titles, English technical content.

---

## Indice / Table of Contents

1. [Pre-requisitos](#1-pre-requisitos--prerequisites)
2. [Configuracao da Conta AWS](#2-configuracao-da-conta-aws--aws-account-setup)
3. [Deploy da Infraestrutura](#3-deploy-da-infraestrutura--infrastructure-deployment)
4. [Configuracao de Autenticacao (Cognito)](#4-configuracao-de-autenticacao--authentication-setup)
5. [Configuracao de Secrets](#5-configuracao-de-secrets--secrets-setup)
6. [Configuracao de Skills](#6-configuracao-de-skills--skills-setup)
7. [Integracao com GitHub](#7-integracao-com-github--github-integration)
8. [Build e Push da Imagem Docker](#8-build-e-push-da-imagem-docker--docker-image)
9. [Teste do Pipeline](#9-teste-do-pipeline--pipeline-testing)
10. [Monitoramento e Alertas](#10-monitoramento-e-alertas--monitoring-and-alerts)
11. [Custos Estimados por Tier](#11-custos-estimados-por-tier--cost-estimates)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Pre-requisitos / Prerequisites

### Software necessario / Required Software

| Tool | Minimum Version | Installation |
|------|----------------|-------------|
| AWS CLI | v2.13+ | `brew install awscli` or [AWS docs](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| Node.js | v20+ | `brew install node` or [nodejs.org](https://nodejs.org) |
| Docker | v24+ | [docker.com](https://www.docker.com/get-started) |
| jq | v1.6+ | `brew install jq` |
| zip | any | Pre-installed on most systems |

### Permissoes AWS necessarias / Required AWS Permissions

The IAM user or role running the deployment needs these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "ec2:*",
        "ecs:*",
        "lambda:*",
        "apigateway:*",
        "dynamodb:*",
        "s3:*",
        "sqs:*",
        "sns:*",
        "cognito-idp:*",
        "cognito-identity:*",
        "wafv2:*",
        "kms:*",
        "secretsmanager:*",
        "logs:*",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:PassRole",
        "iam:GetRole",
        "iam:TagRole",
        "ecr:*",
        "xray:*"
      ],
      "Resource": "*"
    }
  ]
}
```

> **Nota de Seguranca / Security Note:** For production, use a more restrictive policy scoped to the specific resources created by ForgeSquad. The above is for initial deployment only.

### Verificar configuracao / Verify Configuration

```bash
# Check AWS CLI version
aws --version

# Verify credentials
aws sts get-caller-identity

# Verify region
aws configure get region
```

---

## 2. Configuracao da Conta AWS / AWS Account Setup

### 2.1 Criar repositorio ECR / Create ECR Repository

```bash
# Create ECR repository for agent container image
aws ecr create-repository \
  --repository-name forgesquad-agent \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=KMS \
  --region us-east-1

# Note the repository URI from the output
# Example: 123456789012.dkr.ecr.us-east-1.amazonaws.com/forgesquad-agent
```

### 2.2 Configurar perfil AWS (se necessario) / Configure AWS Profile

```bash
# If using named profiles
aws configure --profile forgesquad

# Set as active profile
export AWS_PROFILE=forgesquad

# Or use environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## 3. Deploy da Infraestrutura / Infrastructure Deployment

### Opcao A: CloudFormation (Recomendado / Recommended)

```bash
# Navigate to the infra directory
cd infra/aws

# Deploy for development
./scripts/deploy.sh --env dev --email dev@yourcompany.com

# Deploy for staging
./scripts/deploy.sh --env staging --email qa@yourcompany.com --region us-east-1

# Deploy for production
./scripts/deploy.sh --env prod --email ops@yourcompany.com --region us-east-1

# Dry run (validate only, no deployment)
./scripts/deploy.sh --dry-run --env dev --email dev@yourcompany.com
```

### Opcao B: Terraform

```bash
cd infra/aws/terraform

# Initialize Terraform
terraform init

# Create terraform.tfvars
cat > terraform.tfvars <<'EOF'
project_name       = "forgesquad"
environment        = "dev"
aws_region         = "us-east-1"
notification_email = "dev@yourcompany.com"
agent_image_uri    = "123456789012.dkr.ecr.us-east-1.amazonaws.com/forgesquad-agent:latest"
EOF

# Plan (preview changes)
terraform plan

# Apply
terraform apply

# For production
terraform workspace new prod
terraform apply -var-file="prod.tfvars"
```

### Verificar deploy / Verify Deployment

```bash
# Check CloudFormation stack status
aws cloudformation describe-stacks \
  --stack-name forgesquad-dev \
  --query 'Stacks[0].StackStatus'

# List all resources created
aws cloudformation list-stack-resources \
  --stack-name forgesquad-dev \
  --query 'StackResourceSummaries[].{Type:ResourceType,Name:LogicalResourceId,Status:ResourceStatus}' \
  --output table
```

---

## 4. Configuracao de Autenticacao / Authentication Setup

### 4.1 Configurar Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create a new OAuth 2.0 Client ID
3. Set authorized redirect URI: `https://forgesquad-dev-ACCOUNT_ID.auth.us-east-1.amazoncognito.com/oauth2/idpresponse`
4. Note the Client ID and Client Secret

```bash
# Add Google as identity provider in Cognito
USER_POOL_ID=$(aws cloudformation describe-stacks \
  --stack-name forgesquad-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' \
  --output text)

aws cognito-idp create-identity-provider \
  --user-pool-id $USER_POOL_ID \
  --provider-name Google \
  --provider-type Google \
  --provider-details \
    client_id=YOUR_GOOGLE_CLIENT_ID \
    client_secret=YOUR_GOOGLE_CLIENT_SECRET \
    authorize_scopes="openid email profile" \
  --attribute-mapping \
    email=email \
    name=name \
    username=sub
```

### 4.2 Configurar Microsoft OAuth

1. Go to [Azure Portal > App Registrations](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps)
2. Register a new application
3. Set redirect URI: `https://forgesquad-dev-ACCOUNT_ID.auth.us-east-1.amazoncognito.com/oauth2/idpresponse`
4. Create a client secret under Certificates & Secrets

```bash
aws cognito-idp create-identity-provider \
  --user-pool-id $USER_POOL_ID \
  --provider-name Microsoft \
  --provider-type OIDC \
  --provider-details \
    client_id=YOUR_MICROSOFT_CLIENT_ID \
    client_secret=YOUR_MICROSOFT_CLIENT_SECRET \
    authorize_scopes="openid email profile" \
    oidc_issuer="https://login.microsoftonline.com/YOUR_TENANT_ID/v2.0" \
    attributes_request_method=GET \
  --attribute-mapping \
    email=email \
    name=name \
    username=sub
```

### 4.3 Configurar GitHub OAuth

1. Go to [GitHub Developer Settings > OAuth Apps](https://github.com/settings/developers)
2. Create a new OAuth App
3. Set callback URL: `https://forgesquad-dev-ACCOUNT_ID.auth.us-east-1.amazoncognito.com/oauth2/idpresponse`

```bash
# GitHub uses a custom OIDC-like provider in Cognito
aws cognito-idp create-identity-provider \
  --user-pool-id $USER_POOL_ID \
  --provider-name GitHub \
  --provider-type OIDC \
  --provider-details \
    client_id=YOUR_GITHUB_CLIENT_ID \
    client_secret=YOUR_GITHUB_CLIENT_SECRET \
    authorize_scopes="openid user:email" \
    oidc_issuer="https://token.actions.githubusercontent.com" \
    attributes_request_method=GET \
  --attribute-mapping \
    email=email \
    name=name \
    username=sub
```

### 4.4 Criar usuario administrador / Create Admin User

```bash
# Create admin user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username admin@yourcompany.com \
  --user-attributes \
    Name=email,Value=admin@yourcompany.com \
    Name=email_verified,Value=true \
    Name=name,Value="ForgeSquad Admin" \
  --temporary-password "TempPass123!"

# Add to admin group
aws cognito-idp admin-add-user-to-group \
  --user-pool-id $USER_POOL_ID \
  --username admin@yourcompany.com \
  --group-name admin
```

---

## 5. Configuracao de Secrets / Secrets Setup

### 5.1 Secrets obrigatorios / Required Secrets

```bash
REGION="us-east-1"
ENV="dev"

# Anthropic API Key (for Claude models)
aws secretsmanager put-secret-value \
  --secret-id forgesquad/${ENV}/anthropic-api-key \
  --secret-string '{"apiKey":"sk-ant-xxxxxxxxxxxxx"}' \
  --region $REGION

# GitHub Token (for repository operations)
aws secretsmanager put-secret-value \
  --secret-id forgesquad/${ENV}/github-token \
  --secret-string '{"token":"ghp_xxxxxxxxxxxxx"}' \
  --region $REGION

# Devin API Key (for autonomous coding)
aws secretsmanager put-secret-value \
  --secret-id forgesquad/${ENV}/devin-api-key \
  --secret-string '{"apiKey":"dv_xxxxxxxxxxxxx"}' \
  --region $REGION
```

### 5.2 Secrets opcionais / Optional Secrets

```bash
# StackSpot API Key (for IaC templates)
aws secretsmanager create-secret \
  --name forgesquad/${ENV}/stackspot-api-key \
  --secret-string '{"apiKey":"ss_xxxxxxxxxxxxx"}' \
  --kms-key-id alias/forgesquad-${ENV} \
  --region $REGION

# Copilot API Key (if using GitHub Copilot API)
aws secretsmanager create-secret \
  --name forgesquad/${ENV}/copilot-api-key \
  --secret-string '{"apiKey":"cop_xxxxxxxxxxxxx"}' \
  --kms-key-id alias/forgesquad-${ENV} \
  --region $REGION

# Kiro API Key (for requirements specs)
aws secretsmanager create-secret \
  --name forgesquad/${ENV}/kiro-api-key \
  --secret-string '{"apiKey":"kiro_xxxxxxxxxxxxx"}' \
  --kms-key-id alias/forgesquad-${ENV} \
  --region $REGION
```

### 5.3 Verificar secrets / Verify Secrets

```bash
# List all ForgeSquad secrets
aws secretsmanager list-secrets \
  --filter Key=name,Values=forgesquad/${ENV} \
  --query 'SecretList[].{Name:Name,Created:CreatedDate}' \
  --output table \
  --region $REGION
```

---

## 6. Configuracao de Skills / Skills Setup

ForgeSquad integrates with 4 external tools. Each requires API access configuration.

### 6.1 Devin

Devin handles autonomous coding tasks, bug fixes, and feature implementation.

```bash
# Verify Devin API key works
curl -H "Authorization: Bearer YOUR_DEVIN_API_KEY" \
  https://api.devin.ai/v1/health

# Configure in ForgeSquad
# The agent container reads DEVIN_API_KEY from Secrets Manager automatically
```

### 6.2 GitHub Copilot

Used for pair programming, code suggestions, and inline completions.

```bash
# Copilot integration uses the GitHub token for API access
# Ensure the GitHub token has 'copilot' scope
# No additional configuration needed if GitHub token is set
```

### 6.3 StackSpot

Used for cloud infrastructure, IaC templates, and environment provisioning.

```bash
# Install StackSpot CLI (if deploying from local machine)
curl -fsSL https://stk.stackspot.com/install.sh | bash

# Configure StackSpot credentials
stk login --client-id YOUR_CLIENT_ID --client-secret YOUR_CLIENT_SECRET
```

### 6.4 Kiro

Used for requirements specifications, user story generation, and task breakdown.

```bash
# Kiro integration is configured via its API key in Secrets Manager
# The Business Analyst agent uses Kiro for requirements engineering
```

---

## 7. Integracao com GitHub / GitHub Integration

### 7.1 Criar GitHub App (Recomendado / Recommended)

For production, use a GitHub App instead of a personal access token:

1. Go to [GitHub Settings > Developer Settings > GitHub Apps](https://github.com/settings/apps)
2. Create a new GitHub App with these permissions:
   - **Repository:** Contents (Read & Write), Pull Requests (Read & Write), Issues (Read & Write)
   - **Organization:** Members (Read)
3. Install the app on your organization/repositories

### 7.2 Configurar webhook / Configure Webhook

```bash
# Get the API Gateway URL
API_URL=$(aws cloudformation describe-stacks \
  --stack-name forgesquad-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
  --output text)

echo "Webhook URL: ${API_URL}/webhook"

# Configure in GitHub repository settings:
# Settings > Webhooks > Add webhook
# Payload URL: ${API_URL}/webhook
# Content type: application/json
# Events: Push, Pull Request, Issue Comment
```

### 7.3 Configurar branch protection / Branch Protection

```bash
# Recommended branch protection rules for ForgeSquad-managed repos
gh api repos/OWNER/REPO/branches/main/protection -X PUT -f '{
  "required_status_checks": {
    "strict": true,
    "contexts": ["forgesquad/qa", "forgesquad/security"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null
}'
```

---

## 8. Build e Push da Imagem Docker / Docker Image

### 8.1 Build da imagem / Build Image

```bash
# Navigate to the agent directory (create Dockerfile if not exists)
cd infra/aws/ecs

# Login to ECR
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
REGION="us-east-1"

aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Build the agent image
docker build -t forgesquad-agent:latest .

# Tag for ECR
docker tag forgesquad-agent:latest \
  ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/forgesquad-agent:latest

# Push to ECR
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/forgesquad-agent:latest
```

### 8.2 Atualizar task definition / Update Task Definition

```bash
# After pushing a new image, update the ECS service
aws ecs update-service \
  --cluster forgesquad-dev \
  --service forgesquad-agent-service \
  --force-new-deployment \
  --region $REGION
```

---

## 9. Teste do Pipeline / Pipeline Testing

### 9.1 Obter token de autenticacao / Get Auth Token

```bash
# Get Cognito endpoints
USER_POOL_ID=$(aws cloudformation describe-stacks \
  --stack-name forgesquad-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' \
  --output text)

CLIENT_ID=$(aws cloudformation describe-stacks \
  --stack-name forgesquad-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`UserPoolClientId`].OutputValue' \
  --output text)

# Authenticate (for testing)
TOKEN=$(aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id $CLIENT_ID \
  --auth-parameters USERNAME=admin@yourcompany.com,PASSWORD=YourPassword123! \
  --query 'AuthenticationResult.IdToken' \
  --output text)
```

### 9.2 Iniciar um pipeline / Start a Pipeline

```bash
API_URL=$(aws cloudformation describe-stacks \
  --stack-name forgesquad-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
  --output text)

# Start a pipeline
curl -X POST "${API_URL}/pipeline" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "start",
    "squadName": "my-first-squad",
    "squadConfig": {
      "projectName": "test-project",
      "description": "Testing ForgeSquad pipeline",
      "repository": "https://github.com/org/repo"
    }
  }'
```

### 9.3 Verificar status do pipeline / Check Pipeline Status

```bash
PIPELINE_ID="pipe-xxxxx"  # From the start response

curl -X POST "${API_URL}/pipeline" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"action\": \"status\",
    \"pipelineId\": \"${PIPELINE_ID}\"
  }"
```

### 9.4 Aprovar checkpoint / Approve Checkpoint

```bash
CHECKPOINT_ID="chk-xxxxx"  # From the notification

curl -X POST "${API_URL}/approval" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"action\": \"approve\",
    \"checkpointId\": \"${CHECKPOINT_ID}\",
    \"approvedBy\": \"architect\",
    \"comments\": \"Architecture looks good. Approved.\"
  }"
```

---

## 10. Monitoramento e Alertas / Monitoring and Alerts

### 10.1 Dashboard CloudWatch

After deployment, access the CloudWatch dashboard:

```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=forgesquad-dev
```

The dashboard includes:
- Pipeline execution metrics (invocations, errors, duration)
- Approval gate activity
- SQS queue depths (agent dispatch, approvals, dead letter)
- ECS agent task metrics (CPU, memory, running count)
- API Gateway traffic (requests, 4xx, 5xx, latency)

### 10.2 Alertas configurados / Configured Alerts

| Alert | Trigger | Action |
|-------|---------|--------|
| DLQ Messages | >= 1 message in dead letter queue | Email notification |
| Lambda Errors | >= 5 errors in 10 minutes | Email notification |
| API 5xx Errors | >= 10 errors in 10 minutes | Email notification |

### 10.3 Logs

```bash
# View pipeline runner logs
aws logs tail /aws/lambda/forgesquad-dev-pipeline-runner --follow --region us-east-1

# View approval gate logs
aws logs tail /aws/lambda/forgesquad-dev-approval-gate --follow --region us-east-1

# View agent logs
aws logs tail /ecs/forgesquad-dev/agents --follow --region us-east-1

# Search for errors in logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/forgesquad-dev-pipeline-runner \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s000) \
  --region us-east-1
```

### 10.4 Metricas customizadas / Custom Metrics

```bash
# Pipeline execution count (last 24h)
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=forgesquad-dev-pipeline-runner \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum \
  --region us-east-1
```

### 10.5 Integracao com Slack / Slack Integration (Opcional)

```bash
# Create Slack webhook SNS subscription
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:ACCOUNT_ID:forgesquad-dev-checkpoint-notify \
  --protocol https \
  --notification-endpoint https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK \
  --region us-east-1
```

---

## 11. Custos Estimados por Tier / Cost Estimates

### Tier: Development (~$40/month)

Best for: Individual developers, prototyping, testing.

| Service | Config | Cost/month |
|---------|--------|-----------|
| ECS Fargate | 0.25 vCPU / 512 MB, ~50 task-hours | $2.50 |
| Lambda | 10K invocations, 256 MB | $0.10 |
| API Gateway | 10K requests | $0.04 |
| DynamoDB | On-demand, 1 GB | $1.25 |
| S3 | 5 GB, versioned | $0.15 |
| SQS + SNS | Minimal | $0.03 |
| CloudWatch | Basic | $2.50 |
| KMS | 1 key | $1.03 |
| NAT Gateway | 1 instance | $32.40 |
| **Total** | | **~$40** |

### Tier: Staging (~$113/month)

Best for: QA teams, integration testing, pre-production validation.

| Service | Config | Cost/month |
|---------|--------|-----------|
| ECS Fargate | 0.5 vCPU / 1 GB, ~500 task-hours | $25.00 |
| Lambda | 100K invocations, 512 MB | $1.00 |
| API Gateway | 100K requests | $0.35 |
| DynamoDB | On-demand, 10 GB | $2.50 |
| S3 | 50 GB, versioned | $1.20 |
| SQS + SNS | Moderate | $0.30 |
| CloudWatch | Detailed | $10.00 |
| KMS | 2 keys | $2.03 |
| NAT Gateway | 2 instances (HA) | $64.80 |
| WAF | Basic rules | $6.00 |
| **Total** | | **~$113** |

### Tier: Production (~$492/month)

Best for: Full engineering squads, enterprise deployments.

| Service | Config | Cost/month |
|---------|--------|-----------|
| ECS Fargate | 1 vCPU / 2 GB, ~5K task-hours | $250.00 |
| Lambda | 1M invocations, 1024 MB | $10.00 |
| API Gateway | 1M requests | $3.50 |
| DynamoDB | Provisioned, 100 GB | $25.00 |
| S3 | 500 GB, versioned + lifecycle | $12.00 |
| SQS + SNS | High volume | $3.00 |
| CloudWatch | Full + dashboards | $50.00 |
| Cognito | 5K MAU | $27.75 |
| KMS | 3 keys | $3.09 |
| NAT Gateway | 2 instances, 100 GB data | $73.80 |
| WAF | Full rules + Bot Control | $16.00 |
| CloudFront | 100 GB transfer | $8.50 |
| X-Ray | 1M traces | $5.00 |
| Secrets Manager | 10 secrets | $4.00 |
| **Total** | | **~$492** |

> **Dica de economia / Cost savings tip:** Use NAT Instance instead of NAT Gateway for dev/staging to save ~$30/month. Use VPC endpoints to reduce NAT data transfer costs.

---

## 12. Troubleshooting

### Problemas comuns / Common Issues

#### Stack creation fails with "ROLLBACK_COMPLETE"

```bash
# Check the events for the failure reason
aws cloudformation describe-stack-events \
  --stack-name forgesquad-dev \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].{Resource:LogicalResourceId,Reason:ResourceStatusReason}' \
  --output table

# Delete the failed stack before retrying
aws cloudformation delete-stack --stack-name forgesquad-dev
aws cloudformation wait stack-delete-complete --stack-name forgesquad-dev
```

#### Lambda function timeout

```bash
# Check Lambda execution time
aws logs filter-log-events \
  --log-group-name /aws/lambda/forgesquad-dev-pipeline-runner \
  --filter-pattern "Task timed out" \
  --region us-east-1

# Increase timeout if needed (max 900 seconds)
aws lambda update-function-configuration \
  --function-name forgesquad-dev-pipeline-runner \
  --timeout 900 \
  --region us-east-1
```

#### ECS task fails to start

```bash
# Check stopped task reason
aws ecs describe-tasks \
  --cluster forgesquad-dev \
  --tasks TASK_ARN \
  --query 'tasks[0].{Status:lastStatus,Reason:stoppedReason,Container:containers[0].reason}' \
  --region us-east-1

# Common causes:
# 1. Image not found → verify ECR image URI
# 2. Secrets not found → verify Secrets Manager paths
# 3. Insufficient permissions → check task execution role
```

#### Messages accumulating in Dead Letter Queue

```bash
# Check DLQ message count
aws sqs get-queue-attributes \
  --queue-url https://sqs.us-east-1.amazonaws.com/ACCOUNT_ID/forgesquad-dev-dead-letter \
  --attribute-names ApproximateNumberOfMessages \
  --region us-east-1

# Peek at DLQ messages
aws sqs receive-message \
  --queue-url https://sqs.us-east-1.amazonaws.com/ACCOUNT_ID/forgesquad-dev-dead-letter \
  --max-number-of-messages 5 \
  --region us-east-1
```

#### Cognito authentication issues

```bash
# Check user pool status
aws cognito-idp describe-user-pool \
  --user-pool-id USER_POOL_ID \
  --query 'UserPool.Status' \
  --region us-east-1

# List users
aws cognito-idp list-users \
  --user-pool-id USER_POOL_ID \
  --region us-east-1

# Reset user password
aws cognito-idp admin-set-user-password \
  --user-pool-id USER_POOL_ID \
  --username user@email.com \
  --password NewPassword123! \
  --permanent \
  --region us-east-1
```

### Contato e Suporte / Contact and Support

For issues with ForgeSquad deployment:
1. Check CloudWatch logs for error details
2. Review the [architecture guide](./architecture.md) for service dependencies
3. Verify all secrets are correctly populated in Secrets Manager
4. Ensure the agent container image is available in ECR
