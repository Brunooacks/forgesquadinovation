# Guia de Configuracao — ForgeSquad no Azure / Setup Guide

> **Versao:** 1.0 | **Data:** 2026-03-20 | **Status:** Production-Ready

---

## Indice / Table of Contents

1. [Pre-requisitos](#1-pre-requisitos--prerequisites)
2. [Passo a Passo de Deploy](#2-passo-a-passo-de-deploy--deployment-walkthrough)
3. [Configuracao do Azure AD B2C](#3-configuracao-do-azure-ad-b2c--azure-ad-b2c-setup)
4. [Configuracao de Skills](#4-configuracao-de-skills--skills-configuration)
5. [Integracao com Azure DevOps e GitHub](#5-integracao-com-azure-devops-e-github--devops--github-integration)
6. [Monitoramento com Application Insights](#6-monitoramento-com-application-insights--monitoring)
7. [Custos Estimados por Tier](#7-custos-estimados-por-tier--cost-estimates-by-tier)
8. [Diferencial: Microsoft 365 e Teams](#8-diferencial-integracao-com-microsoft-365-e-teams--m365-integration)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Pre-requisitos / Prerequisites

### Requisitos de Conta Azure / Azure Account Requirements

- **Subscription Azure ativa** com permissoes de Owner ou Contributor
- **Azure AD tenant** (incluso em qualquer subscription)
- **Cota de recursos** suficiente na regiao escolhida:
  - Container Apps: 4+ vCPU
  - API Management: 1 unidade
  - Cosmos DB: Serverless ou 4000 RU Autoscale

### Ferramentas Necessarias / Required Tools

```bash
# Azure CLI (v2.60+)
# Install: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
az version

# Bicep CLI (incluso no Azure CLI)
az bicep version

# Node.js 20+ (para Azure Functions)
node --version

# Azure Functions Core Tools v4
func --version

# Docker (para build de containers)
docker --version

# Git
git --version

# jq (opcional, para parsing de JSON)
jq --version
```

### Instalacao Rapida / Quick Install (macOS)

```bash
# Homebrew
brew install azure-cli node@20 azure-functions-core-tools@4 docker jq

# Login no Azure
az login

# Verificar subscription
az account list --output table

# Selecionar subscription
az account set --subscription "NOME_DA_SUBSCRIPTION"
```

### Instalacao Rapida / Quick Install (Ubuntu/Debian)

```bash
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Azure Functions Core Tools
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update
sudo apt-get install azure-functions-core-tools-4

# jq
sudo apt-get install -y jq
```

### Permissoes Necessarias / Required Permissions

| Permissao | Escopo | Motivo |
|---|---|---|
| Contributor | Subscription | Criar e gerenciar recursos |
| User Access Administrator | Subscription | Atribuir RBAC roles |
| Application Administrator | Azure AD | Registrar aplicacao B2C |
| Key Vault Administrator | Resource Group | Gerenciar secrets |

---

## 2. Passo a Passo de Deploy / Deployment Walkthrough

### 2.1 Clonar o Repositorio / Clone Repository

```bash
git clone https://github.com/your-org/forgesquad.git
cd forgesquad/infra/azure
```

### 2.2 Configurar Variaveis / Configure Variables

```bash
# Editar conforme seu ambiente
export PROJECT_NAME="forgesquad"
export ENVIRONMENT="dev"        # dev | staging | prod
export LOCATION="eastus"        # ou brazilsouth, westeurope, etc.
export SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### 2.3 Deploy Automatizado / Automated Deploy

```bash
# Deploy completo (interativo — pede confirmacao)
./scripts/deploy.sh \
  --environment dev \
  --location eastus

# Deploy para producao com Private Link e Front Door
./scripts/deploy.sh \
  --environment prod \
  --location westeurope \
  --private-link \
  --front-door \
  --apim-sku Standard

# Apenas validar (sem criar recursos)
./scripts/deploy.sh --environment dev --dry-run
```

### 2.4 Deploy Manual com Bicep / Manual Bicep Deploy

```bash
# Criar resource group
az group create \
  --name rg-forgesquad-dev \
  --location eastus \
  --tags project=ForgeSquad environment=dev

# Validar template
az deployment group validate \
  --resource-group rg-forgesquad-dev \
  --template-file bicep/main.bicep \
  --parameters environment=dev projectName=forgesquad

# Deploy
az deployment group create \
  --resource-group rg-forgesquad-dev \
  --template-file bicep/main.bicep \
  --name forgesquad-deploy-$(date +%Y%m%d) \
  --parameters \
    environment=dev \
    projectName=forgesquad \
    agentContainerImage=ghcr.io/forgesquad/agent-runtime:latest \
    apimSku=Developer \
    enablePrivateLink=false \
    enableFrontDoor=false
```

### 2.5 Deploy com ARM Template / ARM Template Deploy

```bash
# Alternativa usando ARM Template JSON
az deployment group create \
  --resource-group rg-forgesquad-dev \
  --template-file arm/azuredeploy.json \
  --parameters \
    environment=dev \
    projectName=forgesquad
```

### 2.6 Deploy das Azure Functions / Deploy Functions

```bash
# Instalar dependencias
cd functions/pipeline-runner && npm install && cd ../..
cd functions/approval-gate && npm install && cd ../..

# Publicar no Azure
func azure functionapp publish func-forgesquad-dev

# Verificar
func azure functionapp list-functions func-forgesquad-dev
```

### 2.7 Build e Push da Imagem do Agente / Build Agent Image

```bash
# Criar Azure Container Registry (se nao existe)
az acr create \
  --resource-group rg-forgesquad-dev \
  --name crforgesquad \
  --sku Basic \
  --admin-enabled false

# Login no ACR
az acr login --name crforgesquad

# Build e push
docker build -t crforgesquad.azurecr.io/forgesquad/agent-runtime:latest .
docker push crforgesquad.azurecr.io/forgesquad/agent-runtime:latest

# Atualizar Container App com nova imagem
az containerapp update \
  --name agent-runtime-forgesquad-dev \
  --resource-group rg-forgesquad-dev \
  --image crforgesquad.azurecr.io/forgesquad/agent-runtime:latest
```

---

## 3. Configuracao do Azure AD B2C / Azure AD B2C Setup

### 3.1 Criar Tenant B2C / Create B2C Tenant

```bash
# Via Portal Azure:
# 1. Azure Portal > Create a resource > Azure Active Directory B2C
# 2. Selecionar "Create a new Azure AD B2C Tenant"
# 3. Organization name: ForgeSquad
# 4. Domain name: forgesquad.onmicrosoft.com
# 5. Country: Brazil ou conforme necessidade
```

### 3.2 Registrar Aplicacao / Register Application

```bash
# No tenant B2C:
# 1. App registrations > New registration
# 2. Name: ForgeSquad API
# 3. Supported account types: "Accounts in any identity provider or organizational directory"
# 4. Redirect URI: https://apim-forgesquad-prod.azure-api.net/callback
# 5. Anotar: Application (client) ID e Directory (tenant) ID
```

### 3.3 Configurar Identity Providers / Configure Identity Providers

#### Google

```
1. Google Cloud Console > APIs & Services > Credentials
2. Create OAuth 2.0 Client ID (Web application)
3. Authorized redirect URI: https://forgesquad.b2clogin.com/forgesquad.onmicrosoft.com/oauth2/authresp
4. No B2C: Identity providers > Google > Inserir Client ID e Secret
```

#### Microsoft

```
1. Azure AD > App registrations > New registration
2. Supported account types: "Accounts in any organizational directory and personal Microsoft accounts"
3. Redirect URI: https://forgesquad.b2clogin.com/forgesquad.onmicrosoft.com/oauth2/authresp
4. No B2C: Identity providers > Microsoft Account > Inserir Client ID e Secret
```

#### GitHub

```
1. GitHub > Settings > Developer settings > OAuth Apps > New
2. Homepage URL: https://forgesquad.example.com
3. Authorization callback URL: https://forgesquad.b2clogin.com/forgesquad.onmicrosoft.com/oauth2/authresp
4. No B2C: Identity providers > GitHub > Inserir Client ID e Secret
```

### 3.4 User Flows / Fluxos de Usuario

```
1. B2C > User flows > New user flow
2. Criar:
   - Sign up and sign in (B2C_1_signup_signin)
   - Password reset (B2C_1_password_reset)
   - Profile editing (B2C_1_profile_edit)
3. Em cada flow, selecionar os identity providers configurados
4. Claims: Display Name, Email, Identity Provider
```

### 3.5 Integrar com APIM / Integrate with APIM

```xml
<!-- Adicionar ao policy do APIM -->
<validate-jwt header-name="Authorization" failed-validation-httpcode="401">
  <openid-config url="https://forgesquad.b2clogin.com/forgesquad.onmicrosoft.com/v2.0/.well-known/openid-configuration?p=B2C_1_signup_signin" />
  <audiences>
    <audience>{APPLICATION_CLIENT_ID}</audience>
  </audiences>
  <issuers>
    <issuer>https://forgesquad.b2clogin.com/{TENANT_ID}/v2.0/</issuer>
  </issuers>
</validate-jwt>
```

---

## 4. Configuracao de Skills / Skills Configuration

### 4.1 Devin (Autonomous Coding)

```bash
# Obter API key em: https://devin.ai/settings/api
az keyvault secret set \
  --vault-name kv-forgesquad \
  --name devin-api-key \
  --value "dvn_xxxxxxxxxxxxxxxxxxxxxxxxxx"

# O agente dev-backend e dev-frontend usam Devin para:
# - Implementacao autonoma de features
# - Bug fixes automatizados
# - Refactoring de codigo
```

### 4.2 GitHub Copilot

```bash
# Configurar token do GitHub com escopo copilot
az keyvault secret set \
  --vault-name kv-forgesquad \
  --name github-token \
  --value "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Copilot e usado pelo agent-runtime para:
# - Sugestoes de codigo inline
# - Pair programming assistido
# - Code review automatizado
```

### 4.3 StackSpot (Cloud Infrastructure)

```bash
# Obter API key em: https://stackspot.com/settings
az keyvault secret set \
  --vault-name kv-forgesquad \
  --name stackspot-api-key \
  --value "stk_xxxxxxxxxxxxxxxxxxxxxxxxxx"

# StackSpot e usado pelo agente devops para:
# - Templates de IaC
# - Provisionamento de ambientes
# - Compliance de infraestrutura
```

### 4.4 Kiro (Requirements)

```bash
# Kiro e integrado via GitHub App
# 1. Instalar Kiro GitHub App no repositorio
# 2. Configurar webhook para Event Grid
# 3. O agente business-analyst usa Kiro para:
#    - Geracao de user stories
#    - Specs de requisitos
#    - Task breakdown
```

### 4.5 OpenAI / Anthropic (LLM Backend)

```bash
# Configurar chaves dos modelos LLM
az keyvault secret set \
  --vault-name kv-forgesquad \
  --name openai-api-key \
  --value "sk-xxxxxxxxxxxxxxxxxxxxxxxxxx"

az keyvault secret set \
  --vault-name kv-forgesquad \
  --name anthropic-api-key \
  --value "sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxx"

# Modelo por agente (configuravel via env vars):
# - Architect, Tech Lead: gpt-4o (mais capaz)
# - BA, QA, DevOps: gpt-4o-mini (equilibrado)
# - Devs, Tech Writer, PM: gpt-4o-mini (eficiente)
```

---

## 5. Integracao com Azure DevOps e GitHub / DevOps & GitHub Integration

### 5.1 GitHub Actions (CI/CD)

```yaml
# .github/workflows/deploy-forgesquad.yml
name: Deploy ForgeSquad Infrastructure

on:
  push:
    branches: [main]
    paths: ['infra/azure/**']

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Deploy Bicep
        uses: azure/arm-deploy@v2
        with:
          resourceGroupName: rg-forgesquad-prod
          template: infra/azure/bicep/main.bicep
          parameters: >
            environment=prod
            projectName=forgesquad
            enablePrivateLink=true
            enableFrontDoor=true
            apimSku=Standard

      - name: Deploy Functions
        run: |
          npm ci --prefix infra/azure/functions/pipeline-runner
          npm ci --prefix infra/azure/functions/approval-gate
          cd infra/azure/functions && func azure functionapp publish func-forgesquad-prod
```

### 5.2 Azure DevOps Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include: [main]
  paths:
    include: ['infra/azure/**']

pool:
  vmImage: ubuntu-latest

variables:
  azureServiceConnection: 'ForgeSquad-Azure'
  resourceGroup: 'rg-forgesquad-prod'
  environment: 'prod'

stages:
  - stage: Validate
    jobs:
      - job: ValidateBicep
        steps:
          - task: AzureCLI@2
            inputs:
              azureSubscription: $(azureServiceConnection)
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az deployment group validate \
                  --resource-group $(resourceGroup) \
                  --template-file infra/azure/bicep/main.bicep \
                  --parameters environment=$(environment)

  - stage: Deploy
    dependsOn: Validate
    jobs:
      - deployment: DeployInfra
        environment: production
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureResourceManagerTemplateDeployment@3
                  inputs:
                    deploymentScope: Resource Group
                    azureResourceManagerConnection: $(azureServiceConnection)
                    resourceGroupName: $(resourceGroup)
                    location: eastus
                    templateLocation: Linked artifact
                    csmFile: infra/azure/bicep/main.bicep
                    overrideParameters: >
                      -environment $(environment)
                      -projectName forgesquad
                      -enablePrivateLink true
                      -enableFrontDoor true
```

### 5.3 Configurar Webhooks para Checkpoints / Checkpoint Webhooks

```bash
# Criar Event Grid subscription para Azure DevOps
az eventgrid event-subscription create \
  --name devops-checkpoint-notifications \
  --source-resource-id "/subscriptions/{sub-id}/resourceGroups/rg-forgesquad-prod/providers/Microsoft.EventGrid/topics/evgt-forgesquad-prod" \
  --endpoint "https://dev.azure.com/{org}/{project}/_apis/public/hooks/events" \
  --endpoint-type webhook \
  --included-event-types "ForgeSquad.Checkpoint.Created"

# Ou para GitHub (via webhook)
az eventgrid event-subscription create \
  --name github-checkpoint-notifications \
  --source-resource-id "/subscriptions/{sub-id}/resourceGroups/rg-forgesquad-prod/providers/Microsoft.EventGrid/topics/evgt-forgesquad-prod" \
  --endpoint "https://api.github.com/repos/{owner}/{repo}/dispatches" \
  --endpoint-type webhook \
  --included-event-types "ForgeSquad.Checkpoint.Created" "ForgeSquad.Checkpoint.Approved"
```

---

## 6. Monitoramento com Application Insights / Monitoring

### 6.1 Dashboard de Monitoramento / Monitoring Dashboard

```bash
# Criar workbook personalizado no Azure Portal
# 1. Application Insights > Workbooks > New
# 2. Adicionar queries KQL:

# Pipeline execution time por fase
requests
| where cloud_RoleName == "func-forgesquad-prod"
| where name startswith "pipeline"
| summarize avg(duration), percentile(duration, 95) by tostring(customDimensions.phaseId)
| order by tostring(customDimensions.phaseId) asc

# Checkpoint approval latency
customEvents
| where name == "checkpoint.created" or name == "checkpoint.approved"
| extend squadId = tostring(customDimensions.squadId)
| extend checkpointId = tostring(customDimensions.checkpointId)
| summarize approvalTime = max(timestamp) - min(timestamp) by squadId, checkpointId

# Agent execution success rate
customEvents
| where name startswith "step."
| summarize
    total = count(),
    success = countif(name == "step.completed"),
    failed = countif(name == "step.failed")
  by tostring(customDimensions.agent)
| extend successRate = round(todouble(success) / todouble(total) * 100, 1)
```

### 6.2 Alertas / Alerts

```bash
# Alerta: Pipeline falhou
az monitor metrics alert create \
  --name "forgesquad-pipeline-failure" \
  --resource-group rg-forgesquad-prod \
  --scopes "/subscriptions/{sub-id}/resourceGroups/rg-forgesquad-prod/providers/Microsoft.Insights/components/appi-forgesquad-prod" \
  --condition "count requests/failed > 5" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 1 \
  --action-group "forgesquad-oncall"

# Alerta: Checkpoint pendente por mais de 24h
# (configurar via Log Analytics alert rule no Portal)
```

### 6.3 Live Metrics / Metricas em Tempo Real

```
1. Application Insights > Live Metrics
2. Filtrar por cloud_RoleName para ver cada componente:
   - func-forgesquad-prod (Functions)
   - agent-runtime-forgesquad-prod (Container Apps)
3. Monitorar: Request rate, failure rate, dependency calls, exceptions
```

---

## 7. Custos Estimados por Tier / Cost Estimates by Tier

### Tier Development (Desenvolvimento)

| Servico | Configuracao | Custo Mensal (USD) |
|---|---|---|
| Container Apps | Consumption, 0-1 replicas | ~$5 |
| Azure Functions | Consumption (free tier) | ~$0 |
| Cosmos DB | Serverless | ~$5 |
| Blob Storage | Hot, <10 GB | ~$2 |
| Service Bus | Standard | ~$10 |
| API Management | Developer | ~$48 |
| Key Vault | Standard | ~$1 |
| App Insights | <5 GB/month | ~$3 |
| Azure AD B2C | Free tier (50K auth/month) | $0 |
| **Total** | | **~$74/mes** |

### Tier Staging (Homologacao)

| Servico | Configuracao | Custo Mensal (USD) |
|---|---|---|
| Container Apps | Consumption, 1-3 replicas | ~$30 |
| Azure Functions | Consumption | ~$5 |
| Cosmos DB | Serverless | ~$20 |
| Blob Storage | Hot, <50 GB | ~$10 |
| Service Bus | Standard | ~$10 |
| API Management | Standard | ~$280 |
| Front Door | Standard | ~$35 |
| Key Vault | Standard | ~$3 |
| App Insights | <20 GB/month | ~$15 |
| Azure AD B2C | P1 | ~$28 |
| **Total** | | **~$436/mes** |

### Tier Production (Producao)

| Servico | Configuracao | Custo Mensal (USD) |
|---|---|---|
| Container Apps | Dedicated D4, 1-10 replicas | ~$150 |
| Azure Functions | EP1 (Elastic Premium) | ~$120 |
| Cosmos DB | Autoscale 4000 RU, zone-redundant | ~$190 |
| Blob Storage | Hot, GRS, <500 GB | ~$50 |
| Service Bus | Premium, 1 MU | ~$668 |
| API Management | Standard | ~$280 |
| Front Door | Premium + WAF | ~$165 |
| Key Vault | Standard | ~$10 |
| App Insights | <50 GB/month | ~$50 |
| Log Analytics | <50 GB/month | ~$45 |
| Azure AD B2C | P2 | ~$56 |
| Private Link | 5 endpoints | ~$50 |
| **Total** | | **~$1,834/mes** |

### Dicas para Otimizacao de Custos / Cost Optimization Tips

1. **Reserved Instances**: Cosmos DB e API Management oferecem descontos de 1-3 anos (ate 65% off)
2. **Dev/Test pricing**: Use subscription Dev/Test para ambientes non-prod
3. **Auto-shutdown**: Container Apps com 0 replicas em dev = custo quase zero quando idle
4. **Commitment tiers**: App Insights e Log Analytics tem commitment tiers com desconto
5. **Azure Hybrid Benefit**: Se tiver licencas Windows Server/SQL Server on-prem

---

## 8. Diferencial: Integracao com Microsoft 365 e Teams / M365 Integration

### 8.1 Microsoft Teams — Notificacoes de Checkpoint

O ForgeSquad no Azure oferece integracao nativa com Microsoft Teams para notificacoes de checkpoint.

```bash
# Criar Event Grid subscription para Teams via Logic App
# 1. Criar Logic App com trigger Event Grid
# 2. Acao: Microsoft Teams > Post message in a channel

# Fluxo:
# Pipeline atinge checkpoint
#   -> Event Grid emite ForgeSquad.Checkpoint.Created
#   -> Logic App recebe evento
#   -> Posta Adaptive Card no canal do Teams
#   -> Stakeholder aprova/rejeita direto no Teams
#   -> Logic App chama approval-gate Function
#   -> Pipeline resume
```

### 8.2 Teams Adaptive Card para Aprovacao / Approval Card

```json
{
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "TextBlock",
      "text": "ForgeSquad Checkpoint Approval",
      "weight": "Bolder",
      "size": "Large"
    },
    {
      "type": "FactSet",
      "facts": [
        { "title": "Squad", "value": "${squadName}" },
        { "title": "Checkpoint", "value": "${checkpointName}" },
        { "title": "Phase", "value": "${phaseName}" },
        { "title": "Steps Completed", "value": "${completedSteps}/24" }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Approve",
      "data": { "decision": "approve" }
    },
    {
      "type": "Action.Submit",
      "title": "Reject",
      "data": { "decision": "reject" }
    },
    {
      "type": "Action.OpenUrl",
      "title": "View Details",
      "url": "https://apim-forgesquad-prod.azure-api.net/pipeline/${squadId}/checkpoints/${checkpointId}"
    }
  ]
}
```

### 8.3 Outlook — Relatorios do Project Manager

```
# Configurar via Logic App:
# 1. Trigger: Event Grid > ForgeSquad.PM.StatusReportGenerated
# 2. Acao: Outlook > Send email com relatorio HTML
# 3. Destinatarios: stakeholders configurados no squad YAML
```

### 8.4 SharePoint — Armazenamento de Documentacao

```
# O agente tech-writer pode publicar documentacao diretamente no SharePoint:
# 1. Registrar Graph API app com permissao Sites.ReadWrite.All
# 2. Configurar SharePoint site: forgesquad.sharepoint.com/sites/documentation
# 3. ADRs, API docs e runbooks sao publicados automaticamente
```

### 8.5 Power BI — Dashboard Executivo

```
# Conectar Power BI ao Cosmos DB para dashboards em tempo real:
# 1. Power BI > Get Data > Azure Cosmos DB
# 2. Usar container 'audit-trail' como source
# 3. Criar metricas:
#    - Pipeline velocity (steps/hora)
#    - Checkpoint approval time
#    - Agent success rate
#    - Cost per pipeline execution
```

---

## 9. Troubleshooting

### Problemas Comuns / Common Issues

#### Container App nao inicia / Container App won't start

```bash
# Verificar logs
az containerapp logs show \
  --name agent-runtime-forgesquad-dev \
  --resource-group rg-forgesquad-dev \
  --type system

# Verificar revisao ativa
az containerapp revision list \
  --name agent-runtime-forgesquad-dev \
  --resource-group rg-forgesquad-dev \
  --output table
```

#### Functions nao executam / Functions not executing

```bash
# Verificar status
az functionapp show \
  --name func-forgesquad-dev \
  --resource-group rg-forgesquad-dev \
  --query "state"

# Verificar logs em tempo real
func azure functionapp logstream func-forgesquad-dev

# Verificar app settings
az functionapp config appsettings list \
  --name func-forgesquad-dev \
  --resource-group rg-forgesquad-dev
```

#### Service Bus mensagens nao processadas / Messages not processed

```bash
# Verificar dead-letter queue
az servicebus queue show \
  --name approval-requests \
  --namespace-name sb-forgesquad-dev \
  --resource-group rg-forgesquad-dev \
  --query "countDetails"
```

#### Cosmos DB throttling (429 errors)

```bash
# Verificar metricas de RU
az cosmosdb sql database throughput show \
  --account-name cosmos-forgesquad-xxx \
  --resource-group rg-forgesquad-dev \
  --name forgesquad-db

# Escalar se necessario
az cosmosdb sql database throughput update \
  --account-name cosmos-forgesquad-xxx \
  --resource-group rg-forgesquad-dev \
  --name forgesquad-db \
  --max-throughput 8000
```

#### APIM retornando 401 / APIM returning 401

```bash
# Verificar JWT validation policy
# Confirmar que o tenant ID e client ID no policy do APIM
# correspondem ao Azure AD B2C configurado

# Testar token manualmente
curl -X POST "https://forgesquad.b2clogin.com/forgesquad.onmicrosoft.com/B2C_1_signup_signin/oauth2/v2.0/token" \
  -d "grant_type=client_credentials&client_id={CLIENT_ID}&client_secret={SECRET}&scope=api://forgesquad/.default"
```

### Comandos Uteis / Useful Commands

```bash
# Listar todos os recursos do ForgeSquad
az resource list \
  --resource-group rg-forgesquad-dev \
  --output table

# Ver custos do mes atual
az consumption usage list \
  --start-date $(date -d "first day of this month" +%Y-%m-%d) \
  --end-date $(date +%Y-%m-%d) \
  --query "[?contains(instanceName, 'forgesquad')].{Name:instanceName, Cost:pretaxCost, Currency:currency}" \
  --output table

# Exportar outputs do deployment
az deployment group show \
  --resource-group rg-forgesquad-dev \
  --name forgesquad-deploy \
  --query "properties.outputs" \
  --output json > deployment-outputs.json

# Restart Container App
az containerapp revision restart \
  --name agent-runtime-forgesquad-dev \
  --resource-group rg-forgesquad-dev \
  --revision <revision-name>

# Verificar saude de todos os servicos
az resource list \
  --resource-group rg-forgesquad-dev \
  --query "[].{Name:name, Type:type, Status:provisioningState}" \
  --output table
```

---

> **Suporte / Support**: Para questoes sobre esta infraestrutura, abra uma issue no repositorio ou contate a equipe de plataforma.
