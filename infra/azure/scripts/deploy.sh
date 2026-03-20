#!/usr/bin/env bash
# ============================================================================
# ForgeSquad — Azure Deployment Script
# Script de deploy para infraestrutura Azure do ForgeSquad
# Version: 1.0 | Date: 2026-03-20
# ============================================================================

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ─── Configuration (defaults — override via env vars or flags) ───────────────

PROJECT_NAME="${PROJECT_NAME:-forgesquad}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-eastus}"
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-${PROJECT_NAME}-${ENVIRONMENT}}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-}"
ENABLE_PRIVATE_LINK="${ENABLE_PRIVATE_LINK:-false}"
ENABLE_FRONT_DOOR="${ENABLE_FRONT_DOOR:-false}"
APIM_SKU="${APIM_SKU:-Developer}"
AGENT_IMAGE="${AGENT_IMAGE:-ghcr.io/forgesquad/agent-runtime:latest}"
BICEP_FILE="${BICEP_FILE:-$(dirname "$0")/../bicep/main.bicep}"
DRY_RUN="${DRY_RUN:-false}"

# ─── Functions ───────────────────────────────────────────────────────────────

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
  echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}  $1${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

usage() {
  cat <<EOF
ForgeSquad Azure Deployment Script

Usage: $0 [OPTIONS]

Options:
  -e, --environment   Environment (dev|staging|prod)     [default: dev]
  -l, --location      Azure region                       [default: eastus]
  -r, --resource-group Resource group name               [default: rg-forgesquad-{env}]
  -s, --subscription  Azure subscription ID              [required if multiple subs]
  -p, --private-link  Enable Private Link endpoints      [default: false]
  -f, --front-door    Enable Azure Front Door + WAF      [default: false]
  -a, --apim-sku      API Management SKU                 [default: Developer]
  -i, --image         Agent container image              [default: ghcr.io/forgesquad/agent-runtime:latest]
  -d, --dry-run       Validate template without deploying
  -h, --help          Show this help message

Examples:
  $0 -e dev -l eastus
  $0 -e prod -l westeurope -p -f -a Standard
  $0 -e staging --dry-run

Environment Variables:
  PROJECT_NAME, ENVIRONMENT, LOCATION, RESOURCE_GROUP,
  SUBSCRIPTION_ID, ENABLE_PRIVATE_LINK, ENABLE_FRONT_DOOR,
  APIM_SKU, AGENT_IMAGE, BICEP_FILE, DRY_RUN
EOF
  exit 0
}

# ─── Parse Arguments ─────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--environment) ENVIRONMENT="$2"; shift 2 ;;
    -l|--location) LOCATION="$2"; shift 2 ;;
    -r|--resource-group) RESOURCE_GROUP="$2"; shift 2 ;;
    -s|--subscription) SUBSCRIPTION_ID="$2"; shift 2 ;;
    -p|--private-link) ENABLE_PRIVATE_LINK="true"; shift ;;
    -f|--front-door) ENABLE_FRONT_DOOR="true"; shift ;;
    -a|--apim-sku) APIM_SKU="$2"; shift 2 ;;
    -i|--image) AGENT_IMAGE="$2"; shift 2 ;;
    -d|--dry-run) DRY_RUN="true"; shift ;;
    -h|--help) usage ;;
    *) log_error "Unknown option: $1"; usage ;;
  esac
done

# Update resource group name if not explicitly set
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-${PROJECT_NAME}-${ENVIRONMENT}}"

# ─── Banner ──────────────────────────────────────────────────────────────────

echo -e "${CYAN}"
cat <<'BANNER'

  ╔═══════════════════════════════════════════════════════════╗
  ║                                                           ║
  ║   ForgeSquad — Azure Deployment                           ║
  ║   Multi-Agent Orchestration Framework                     ║
  ║                                                           ║
  ║   9 Agents | 10 Phases | 24 Steps | 9 Checkpoints        ║
  ║                                                           ║
  ╚═══════════════════════════════════════════════════════════╝

BANNER
echo -e "${NC}"

# ─── Step 1: Prerequisites Check ────────────────────────────────────────────

log_step "Step 1/7: Verificacao de Pre-requisitos / Prerequisites Check"

# Check Azure CLI
if ! command -v az &>/dev/null; then
  log_error "Azure CLI (az) is not installed."
  echo "  Install: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
  exit 1
fi
AZ_VERSION=$(az version --query '"azure-cli"' -o tsv 2>/dev/null)
log_success "Azure CLI found: v${AZ_VERSION}"

# Check login status
if ! az account show &>/dev/null; then
  log_error "Not logged in to Azure. Run: az login"
  exit 1
fi
CURRENT_ACCOUNT=$(az account show --query "user.name" -o tsv)
log_success "Logged in as: ${CURRENT_ACCOUNT}"

# Set subscription if provided
if [[ -n "${SUBSCRIPTION_ID}" ]]; then
  log_info "Setting subscription: ${SUBSCRIPTION_ID}"
  az account set --subscription "${SUBSCRIPTION_ID}"
fi

CURRENT_SUB=$(az account show --query "id" -o tsv)
CURRENT_SUB_NAME=$(az account show --query "name" -o tsv)
log_success "Subscription: ${CURRENT_SUB_NAME} (${CURRENT_SUB})"

# Check Bicep
if ! az bicep version &>/dev/null; then
  log_warn "Bicep CLI not found. Installing..."
  az bicep install
fi
BICEP_VERSION=$(az bicep version 2>/dev/null | head -1)
log_success "Bicep: ${BICEP_VERSION}"

# Check jq (optional but recommended)
if command -v jq &>/dev/null; then
  log_success "jq found: $(jq --version)"
else
  log_warn "jq not found (optional, but recommended for output parsing)"
fi

# Validate Bicep file exists
if [[ ! -f "${BICEP_FILE}" ]]; then
  log_error "Bicep file not found: ${BICEP_FILE}"
  exit 1
fi
log_success "Bicep template: ${BICEP_FILE}"

# Check required resource providers
log_info "Checking Azure resource providers..."
REQUIRED_PROVIDERS=(
  "Microsoft.App"
  "Microsoft.Web"
  "Microsoft.DocumentDB"
  "Microsoft.Storage"
  "Microsoft.ServiceBus"
  "Microsoft.EventGrid"
  "Microsoft.KeyVault"
  "Microsoft.ApiManagement"
  "Microsoft.Insights"
  "Microsoft.OperationalInsights"
  "Microsoft.Network"
)

for provider in "${REQUIRED_PROVIDERS[@]}"; do
  STATUS=$(az provider show --namespace "${provider}" --query "registrationState" -o tsv 2>/dev/null || echo "NotRegistered")
  if [[ "${STATUS}" == "Registered" ]]; then
    log_success "Provider ${provider}: Registered"
  else
    log_warn "Provider ${provider}: ${STATUS} — Registering..."
    az provider register --namespace "${provider}" --wait
    log_success "Provider ${provider}: Registered"
  fi
done

# ─── Step 2: Configuration Summary ──────────────────────────────────────────

log_step "Step 2/7: Resumo da Configuracao / Configuration Summary"

cat <<EOF
  Project Name:      ${PROJECT_NAME}
  Environment:       ${ENVIRONMENT}
  Location:          ${LOCATION}
  Resource Group:    ${RESOURCE_GROUP}
  Subscription:      ${CURRENT_SUB_NAME}
  APIM SKU:          ${APIM_SKU}
  Agent Image:       ${AGENT_IMAGE}
  Private Link:      ${ENABLE_PRIVATE_LINK}
  Front Door + WAF:  ${ENABLE_FRONT_DOOR}
  Dry Run:           ${DRY_RUN}
  Bicep File:        ${BICEP_FILE}
EOF

echo ""
if [[ "${DRY_RUN}" == "true" ]]; then
  log_warn "DRY RUN MODE — template will be validated but not deployed"
fi

read -rp "$(echo -e "${YELLOW}Continue with deployment? (y/N): ${NC}")" CONFIRM
if [[ "${CONFIRM}" != "y" && "${CONFIRM}" != "Y" ]]; then
  log_info "Deployment cancelled."
  exit 0
fi

# ─── Step 3: Resource Group ─────────────────────────────────────────────────

log_step "Step 3/7: Criacao do Resource Group / Resource Group Creation"

if az group show --name "${RESOURCE_GROUP}" &>/dev/null; then
  log_info "Resource group '${RESOURCE_GROUP}' already exists."
else
  log_info "Creating resource group '${RESOURCE_GROUP}' in '${LOCATION}'..."
  az group create \
    --name "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --tags project=ForgeSquad environment="${ENVIRONMENT}" managedBy=Bicep
  log_success "Resource group created: ${RESOURCE_GROUP}"
fi

# ─── Step 4: Template Validation ────────────────────────────────────────────

log_step "Step 4/7: Validacao do Template / Template Validation"

log_info "Validating Bicep template..."
VALIDATION_RESULT=$(az deployment group validate \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file "${BICEP_FILE}" \
  --parameters \
    environment="${ENVIRONMENT}" \
    projectName="${PROJECT_NAME}" \
    agentContainerImage="${AGENT_IMAGE}" \
    apimSku="${APIM_SKU}" \
    enablePrivateLink="${ENABLE_PRIVATE_LINK}" \
    enableFrontDoor="${ENABLE_FRONT_DOOR}" \
  2>&1)

if [[ $? -eq 0 ]]; then
  log_success "Template validation passed"
else
  log_error "Template validation failed:"
  echo "${VALIDATION_RESULT}"
  exit 1
fi

# What-if analysis
log_info "Running what-if analysis..."
az deployment group what-if \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file "${BICEP_FILE}" \
  --parameters \
    environment="${ENVIRONMENT}" \
    projectName="${PROJECT_NAME}" \
    agentContainerImage="${AGENT_IMAGE}" \
    apimSku="${APIM_SKU}" \
    enablePrivateLink="${ENABLE_PRIVATE_LINK}" \
    enableFrontDoor="${ENABLE_FRONT_DOOR}" \
  --result-format FullResourcePayloads 2>/dev/null || true

if [[ "${DRY_RUN}" == "true" ]]; then
  log_success "Dry run complete. No resources were deployed."
  exit 0
fi

# ─── Step 5: Deploy Infrastructure ──────────────────────────────────────────

log_step "Step 5/7: Deploy da Infraestrutura / Infrastructure Deployment"

DEPLOYMENT_NAME="forgesquad-${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S)"
log_info "Starting deployment: ${DEPLOYMENT_NAME}"
log_info "This may take 15-30 minutes (APIM provisioning is the slowest)..."

DEPLOY_OUTPUT=$(az deployment group create \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file "${BICEP_FILE}" \
  --name "${DEPLOYMENT_NAME}" \
  --parameters \
    environment="${ENVIRONMENT}" \
    projectName="${PROJECT_NAME}" \
    agentContainerImage="${AGENT_IMAGE}" \
    apimSku="${APIM_SKU}" \
    enablePrivateLink="${ENABLE_PRIVATE_LINK}" \
    enableFrontDoor="${ENABLE_FRONT_DOOR}" \
  --query "properties.outputs" \
  -o json 2>&1)

if [[ $? -ne 0 ]]; then
  log_error "Deployment failed!"
  echo "${DEPLOY_OUTPUT}"
  log_info "Check deployment status: az deployment group show -g ${RESOURCE_GROUP} -n ${DEPLOYMENT_NAME}"
  exit 1
fi

log_success "Deployment completed successfully!"

# ─── Step 6: Post-Deployment Configuration ──────────────────────────────────

log_step "Step 6/7: Configuracao Pos-Deploy / Post-Deployment Configuration"

# Extract outputs
log_info "Extracting deployment outputs..."

COSMOS_ENDPOINT=$(echo "${DEPLOY_OUTPUT}" | jq -r '.cosmosDbEndpoint.value // empty' 2>/dev/null || echo "")
STORAGE_NAME=$(echo "${DEPLOY_OUTPUT}" | jq -r '.storageAccountName.value // empty' 2>/dev/null || echo "")
KEYVAULT_URI=$(echo "${DEPLOY_OUTPUT}" | jq -r '.keyVaultUri.value // empty' 2>/dev/null || echo "")
APIM_URL=$(echo "${DEPLOY_OUTPUT}" | jq -r '.apimGatewayUrl.value // empty' 2>/dev/null || echo "")
FUNC_HOSTNAME=$(echo "${DEPLOY_OUTPUT}" | jq -r '.functionAppHostname.value // empty' 2>/dev/null || echo "")
SB_NAMESPACE=$(echo "${DEPLOY_OUTPUT}" | jq -r '.serviceBusNamespace.value // empty' 2>/dev/null || echo "")
APPINSIGHTS_CS=$(echo "${DEPLOY_OUTPUT}" | jq -r '.appInsightsConnectionString.value // empty' 2>/dev/null || echo "")

cat <<EOF

  Deployment Outputs:
  ──────────────────────────────────────────
  Cosmos DB Endpoint:    ${COSMOS_ENDPOINT}
  Storage Account:       ${STORAGE_NAME}
  Key Vault URI:         ${KEYVAULT_URI}
  APIM Gateway URL:      ${APIM_URL}
  Function App:          ${FUNC_HOSTNAME}
  Service Bus:           ${SB_NAMESPACE}
  ──────────────────────────────────────────

EOF

# Store initial secrets in Key Vault (if Key Vault URI available)
if [[ -n "${KEYVAULT_URI}" ]]; then
  KEYVAULT_NAME=$(echo "${KEYVAULT_URI}" | sed 's|https://||;s|.vault.azure.net/||')

  log_info "Setting initial Key Vault secrets..."

  # Application Insights connection string
  if [[ -n "${APPINSIGHTS_CS}" ]]; then
    az keyvault secret set \
      --vault-name "${KEYVAULT_NAME}" \
      --name "appinsights-instrumentation-key" \
      --value "${APPINSIGHTS_CS}" \
      --only-show-errors &>/dev/null
    log_success "Secret set: appinsights-instrumentation-key"
  fi

  # Placeholder secrets (user must update with real values)
  PLACEHOLDER_SECRETS=(
    "openai-api-key:REPLACE_WITH_OPENAI_API_KEY"
    "anthropic-api-key:REPLACE_WITH_ANTHROPIC_API_KEY"
    "github-token:REPLACE_WITH_GITHUB_TOKEN"
    "devin-api-key:REPLACE_WITH_DEVIN_API_KEY"
    "stackspot-api-key:REPLACE_WITH_STACKSPOT_API_KEY"
  )

  for secret_pair in "${PLACEHOLDER_SECRETS[@]}"; do
    SECRET_NAME="${secret_pair%%:*}"
    SECRET_VALUE="${secret_pair##*:}"
    # Only set if not already exists
    if ! az keyvault secret show --vault-name "${KEYVAULT_NAME}" --name "${SECRET_NAME}" &>/dev/null; then
      az keyvault secret set \
        --vault-name "${KEYVAULT_NAME}" \
        --name "${SECRET_NAME}" \
        --value "${SECRET_VALUE}" \
        --only-show-errors &>/dev/null
      log_warn "Placeholder secret set: ${SECRET_NAME} (UPDATE WITH REAL VALUE)"
    else
      log_info "Secret already exists: ${SECRET_NAME}"
    fi
  done
fi

# Configure diagnostic settings
log_info "Configuring diagnostic settings..."
az monitor diagnostic-settings create \
  --resource "${RESOURCE_GROUP}" \
  --resource-type "Microsoft.Resources/resourceGroups" \
  --name "forgesquad-diagnostics" \
  --logs '[{"categoryGroup":"allLogs","enabled":true}]' \
  --workspace "log-${PROJECT_NAME}-${ENVIRONMENT}" \
  --only-show-errors 2>/dev/null || log_warn "Diagnostic settings may need manual configuration"

# ─── Step 7: Health Checks ──────────────────────────────────────────────────

log_step "Step 7/7: Verificacao de Saude / Health Checks"

HEALTH_PASS=0
HEALTH_FAIL=0

check_health() {
  local name="$1"
  local check_cmd="$2"

  if eval "${check_cmd}" &>/dev/null; then
    log_success "${name}: Healthy"
    ((HEALTH_PASS++))
  else
    log_error "${name}: Unhealthy or not ready"
    ((HEALTH_FAIL++))
  fi
}

# Check resource group
check_health "Resource Group" "az group show -n ${RESOURCE_GROUP}"

# Check Key Vault
check_health "Key Vault" "az keyvault show -n ${KEYVAULT_NAME:-kv-unknown} 2>/dev/null"

# Check Cosmos DB
if [[ -n "${COSMOS_ENDPOINT}" ]]; then
  COSMOS_NAME=$(echo "${COSMOS_ENDPOINT}" | sed 's|https://||;s|.documents.azure.com.*||')
  check_health "Cosmos DB" "az cosmosdb show -n ${COSMOS_NAME} -g ${RESOURCE_GROUP}"
fi

# Check Storage Account
if [[ -n "${STORAGE_NAME}" ]]; then
  check_health "Storage Account" "az storage account show -n ${STORAGE_NAME} -g ${RESOURCE_GROUP}"
fi

# Check Service Bus
SB_NAME="sb-${PROJECT_NAME}-${ENVIRONMENT}"
check_health "Service Bus" "az servicebus namespace show -n ${SB_NAME} -g ${RESOURCE_GROUP}"

# Check Function App
FUNC_NAME="func-${PROJECT_NAME}-${ENVIRONMENT}"
check_health "Function App" "az functionapp show -n ${FUNC_NAME} -g ${RESOURCE_GROUP}"

# Check Container Apps Environment
CAE_NAME="cae-${PROJECT_NAME}-${ENVIRONMENT}"
check_health "Container Apps Env" "az containerapp env show -n ${CAE_NAME} -g ${RESOURCE_GROUP}"

# Check API Management
APIM_NAME="apim-${PROJECT_NAME}-${ENVIRONMENT}"
check_health "API Management" "az apim show -n ${APIM_NAME} -g ${RESOURCE_GROUP}"

# Summary
echo ""
echo -e "  Health Check Results: ${GREEN}${HEALTH_PASS} passed${NC} / ${RED}${HEALTH_FAIL} failed${NC}"
echo ""

# ─── Completion ──────────────────────────────────────────────────────────────

echo -e "${GREEN}"
cat <<'COMPLETE'

  ╔═══════════════════════════════════════════════════════════╗
  ║                                                           ║
  ║   ForgeSquad deployment complete!                         ║
  ║                                                           ║
  ╚═══════════════════════════════════════════════════════════╝

COMPLETE
echo -e "${NC}"

cat <<EOF
  Next Steps / Proximos Passos:
  ─────────────────────────────────────────────────────────────

  1. Update Key Vault secrets with real API keys:
     az keyvault secret set --vault-name ${KEYVAULT_NAME:-kv-forgesquad} \\
       --name openai-api-key --value "sk-..."

  2. Build and push agent container image:
     docker build -t crforgesquad.azurecr.io/forgesquad/agent-runtime:latest .
     docker push crforgesquad.azurecr.io/forgesquad/agent-runtime:latest

  3. Deploy Azure Functions code:
     cd functions && func azure functionapp publish ${FUNC_NAME}

  4. Configure Azure AD B2C:
     See setup-guide.md for detailed instructions

  5. Set up CI/CD pipeline:
     See .github/workflows/ or azure-pipelines.yml

  6. Monitor with Application Insights:
     az monitor app-insights component show -a appi-${PROJECT_NAME}-${ENVIRONMENT} \\
       -g ${RESOURCE_GROUP}

EOF

if [[ ${HEALTH_FAIL} -gt 0 ]]; then
  log_warn "Some health checks failed. Resources may still be provisioning."
  log_info "Re-run health checks in a few minutes with:"
  echo "  az deployment group show -g ${RESOURCE_GROUP} -n ${DEPLOYMENT_NAME} --query 'properties.provisioningState'"
  exit 1
fi

exit 0
