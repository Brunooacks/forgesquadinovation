#!/usr/bin/env bash
# ==============================================================================
# ForgeSquad — AWS Deployment Script
#
# Deploys the complete ForgeSquad infrastructure via CloudFormation.
# Usage: ./deploy.sh --env <dev|staging|prod> --email <notification@email.com>
# ==============================================================================

set -euo pipefail

# --- Cores / Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Defaults ---
ENVIRONMENT="dev"
NOTIFICATION_EMAIL=""
REGION="us-east-1"
PROJECT_NAME="forgesquad"
AGENT_IMAGE_URI=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"
CFN_TEMPLATE="${INFRA_DIR}/cloudformation/main.yaml"
LAMBDA_DIR="${INFRA_DIR}/lambda"

# ==============================================================================
# Funcoes Auxiliares / Helper Functions
# ==============================================================================

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

usage() {
  cat <<EOF
ForgeSquad AWS Deployment Script

Usage: $0 [options]

Options:
  --env <environment>     Environment: dev, staging, prod (default: dev)
  --email <email>         Notification email (required)
  --region <region>       AWS region (default: us-east-1)
  --image <uri>           Agent container image URI (optional)
  --project <name>        Project name (default: forgesquad)
  --dry-run               Validate template without deploying
  --destroy               Delete the CloudFormation stack
  -h, --help              Show this help message

Examples:
  $0 --env dev --email dev@company.com
  $0 --env prod --email ops@company.com --region eu-west-1
  $0 --dry-run --env staging --email qa@company.com
  $0 --destroy --env dev
EOF
  exit 0
}

# ==============================================================================
# Argumentos / Argument Parsing
# ==============================================================================

DRY_RUN=false
DESTROY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --env)        ENVIRONMENT="$2"; shift 2 ;;
    --email)      NOTIFICATION_EMAIL="$2"; shift 2 ;;
    --region)     REGION="$2"; shift 2 ;;
    --image)      AGENT_IMAGE_URI="$2"; shift 2 ;;
    --project)    PROJECT_NAME="$2"; shift 2 ;;
    --dry-run)    DRY_RUN=true; shift ;;
    --destroy)    DESTROY=true; shift ;;
    -h|--help)    usage ;;
    *)            log_error "Unknown option: $1"; usage ;;
  esac
done

STACK_NAME="${PROJECT_NAME}-${ENVIRONMENT}"

# ==============================================================================
# 1. Verificacao de Pre-requisitos / Prerequisites Check
# ==============================================================================

check_prerequisites() {
  log_info "Checking prerequisites..."

  # AWS CLI
  if ! command -v aws &>/dev/null; then
    log_error "AWS CLI not found. Install: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
    exit 1
  fi
  log_success "AWS CLI: $(aws --version 2>&1 | head -1)"

  # AWS credentials
  if ! aws sts get-caller-identity &>/dev/null; then
    log_error "AWS credentials not configured. Run 'aws configure' or set AWS_PROFILE."
    exit 1
  fi

  local ACCOUNT_ID
  ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
  log_success "AWS Account: ${ACCOUNT_ID}"
  log_success "AWS Region: ${REGION}"

  # jq (for JSON processing)
  if ! command -v jq &>/dev/null; then
    log_warn "jq not found. Some post-deployment steps may be limited."
  else
    log_success "jq: $(jq --version)"
  fi

  # Validate environment
  if [[ ! "${ENVIRONMENT}" =~ ^(dev|staging|prod)$ ]]; then
    log_error "Invalid environment: ${ENVIRONMENT}. Must be dev, staging, or prod."
    exit 1
  fi
  log_success "Environment: ${ENVIRONMENT}"

  # Validate email
  if [[ -z "${NOTIFICATION_EMAIL}" && "${DESTROY}" == "false" ]]; then
    log_error "Notification email is required. Use --email <email>"
    exit 1
  fi

  # Validate CloudFormation template exists
  if [[ ! -f "${CFN_TEMPLATE}" ]]; then
    log_error "CloudFormation template not found: ${CFN_TEMPLATE}"
    exit 1
  fi
  log_success "Template: ${CFN_TEMPLATE}"

  echo ""
}

# ==============================================================================
# 2. Empacotamento das Lambdas / Package Lambda Functions
# ==============================================================================

package_lambdas() {
  log_info "Packaging Lambda functions..."

  # Pipeline Runner
  local PIPELINE_DIR="${LAMBDA_DIR}/pipeline-runner"
  if [[ -f "${PIPELINE_DIR}/index.js" ]]; then
    (cd "${PIPELINE_DIR}" && zip -q pipeline-runner.zip index.js 2>/dev/null || true)
    log_success "Packaged pipeline-runner.zip"
  else
    log_warn "pipeline-runner/index.js not found, skipping packaging"
  fi

  # Approval Gate
  local APPROVAL_DIR="${LAMBDA_DIR}/approval-gate"
  if [[ -f "${APPROVAL_DIR}/index.js" ]]; then
    (cd "${APPROVAL_DIR}" && zip -q approval-gate.zip index.js 2>/dev/null || true)
    log_success "Packaged approval-gate.zip"
  else
    log_warn "approval-gate/index.js not found, skipping packaging"
  fi

  echo ""
}

# ==============================================================================
# 3. Validacao do Template / Template Validation
# ==============================================================================

validate_template() {
  log_info "Validating CloudFormation template..."

  if aws cloudformation validate-template \
    --template-body "file://${CFN_TEMPLATE}" \
    --region "${REGION}" &>/dev/null; then
    log_success "Template validation passed"
  else
    log_error "Template validation failed"
    aws cloudformation validate-template \
      --template-body "file://${CFN_TEMPLATE}" \
      --region "${REGION}"
    exit 1
  fi

  echo ""
}

# ==============================================================================
# 4. Deploy do Stack / Stack Deployment
# ==============================================================================

deploy_stack() {
  log_info "Deploying CloudFormation stack: ${STACK_NAME}"

  local PARAMETERS=(
    "ParameterKey=EnvironmentName,ParameterValue=${ENVIRONMENT}"
    "ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME}"
    "ParameterKey=NotificationEmail,ParameterValue=${NOTIFICATION_EMAIL}"
  )

  if [[ -n "${AGENT_IMAGE_URI}" ]]; then
    PARAMETERS+=("ParameterKey=AgentImageUri,ParameterValue=${AGENT_IMAGE_URI}")
  fi

  # Check if stack exists
  local STACK_EXISTS=false
  if aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" &>/dev/null; then
    STACK_EXISTS=true
  fi

  if [[ "${STACK_EXISTS}" == "true" ]]; then
    log_info "Stack exists. Updating..."

    aws cloudformation update-stack \
      --stack-name "${STACK_NAME}" \
      --template-body "file://${CFN_TEMPLATE}" \
      --parameters "${PARAMETERS[@]}" \
      --capabilities CAPABILITY_NAMED_IAM \
      --region "${REGION}" \
      --tags "Key=Project,Value=${PROJECT_NAME}" "Key=Environment,Value=${ENVIRONMENT}" \
      2>/dev/null || {
        local EXIT_CODE=$?
        if aws cloudformation describe-stacks --stack-name "${STACK_NAME}" --region "${REGION}" 2>&1 | grep -q "No updates"; then
          log_warn "No changes to deploy."
          return 0
        fi
        return ${EXIT_CODE}
      }

    log_info "Waiting for stack update to complete..."
    aws cloudformation wait stack-update-complete \
      --stack-name "${STACK_NAME}" \
      --region "${REGION}"
  else
    log_info "Creating new stack..."

    aws cloudformation create-stack \
      --stack-name "${STACK_NAME}" \
      --template-body "file://${CFN_TEMPLATE}" \
      --parameters "${PARAMETERS[@]}" \
      --capabilities CAPABILITY_NAMED_IAM \
      --region "${REGION}" \
      --tags "Key=Project,Value=${PROJECT_NAME}" "Key=Environment,Value=${ENVIRONMENT}" \
      --on-failure ROLLBACK

    log_info "Waiting for stack creation to complete (this may take 10-15 minutes)..."
    aws cloudformation wait stack-create-complete \
      --stack-name "${STACK_NAME}" \
      --region "${REGION}"
  fi

  log_success "Stack deployment completed successfully!"
  echo ""
}

# ==============================================================================
# 5. Destruicao do Stack / Stack Destruction
# ==============================================================================

destroy_stack() {
  log_warn "Destroying CloudFormation stack: ${STACK_NAME}"
  echo ""

  read -rp "Are you sure you want to destroy '${STACK_NAME}' in '${REGION}'? (yes/no): " CONFIRM
  if [[ "${CONFIRM}" != "yes" ]]; then
    log_info "Destruction cancelled."
    exit 0
  fi

  if [[ "${ENVIRONMENT}" == "prod" ]]; then
    read -rp "This is a PRODUCTION stack. Type the stack name to confirm: " CONFIRM_NAME
    if [[ "${CONFIRM_NAME}" != "${STACK_NAME}" ]]; then
      log_error "Stack name does not match. Destruction cancelled."
      exit 1
    fi
  fi

  aws cloudformation delete-stack \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}"

  log_info "Waiting for stack deletion..."
  aws cloudformation wait stack-delete-complete \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}"

  log_success "Stack ${STACK_NAME} destroyed."
}

# ==============================================================================
# 6. Configuracao Pos-Deploy / Post-Deployment Configuration
# ==============================================================================

post_deployment() {
  log_info "Running post-deployment configuration..."

  # Get stack outputs
  local OUTPUTS
  OUTPUTS=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" \
    --query 'Stacks[0].Outputs' \
    --output json 2>/dev/null)

  if command -v jq &>/dev/null && [[ -n "${OUTPUTS}" ]]; then
    echo ""
    log_info "=== Stack Outputs ==="
    echo "${OUTPUTS}" | jq -r '.[] | "  \(.OutputKey): \(.OutputValue)"'
    echo ""

    # Extract key values
    local API_URL
    API_URL=$(echo "${OUTPUTS}" | jq -r '.[] | select(.OutputKey=="ApiGatewayUrl") | .OutputValue' 2>/dev/null || echo "N/A")
    local USER_POOL_ID
    USER_POOL_ID=$(echo "${OUTPUTS}" | jq -r '.[] | select(.OutputKey=="UserPoolId") | .OutputValue' 2>/dev/null || echo "N/A")
    local COGNITO_DOMAIN
    COGNITO_DOMAIN=$(echo "${OUTPUTS}" | jq -r '.[] | select(.OutputKey=="CognitoDomain") | .OutputValue' 2>/dev/null || echo "N/A")

    echo ""
    log_info "=== Quick Reference ==="
    echo "  API Endpoint:    ${API_URL}"
    echo "  Cognito Pool:    ${USER_POOL_ID}"
    echo "  Auth Domain:     ${COGNITO_DOMAIN}"
    echo ""
  fi

  # Reminder about SNS subscription confirmation
  log_warn "IMPORTANT: Check your email (${NOTIFICATION_EMAIL}) to confirm the SNS subscription."
  echo ""

  # Reminder about secrets
  log_warn "IMPORTANT: Populate secrets in AWS Secrets Manager:"
  echo "  aws secretsmanager put-secret-value --secret-id ${PROJECT_NAME}/${ENVIRONMENT}/anthropic-api-key --secret-string 'YOUR_KEY' --region ${REGION}"
  echo "  aws secretsmanager put-secret-value --secret-id ${PROJECT_NAME}/${ENVIRONMENT}/github-token --secret-string 'YOUR_TOKEN' --region ${REGION}"
  echo "  aws secretsmanager put-secret-value --secret-id ${PROJECT_NAME}/${ENVIRONMENT}/devin-api-key --secret-string 'YOUR_KEY' --region ${REGION}"
  echo ""
}

# ==============================================================================
# 7. Verificacao de Saude / Health Check
# ==============================================================================

health_check() {
  log_info "Running health checks..."

  # Check stack status
  local STACK_STATUS
  STACK_STATUS=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${REGION}" \
    --query 'Stacks[0].StackStatus' \
    --output text 2>/dev/null)

  if [[ "${STACK_STATUS}" == "CREATE_COMPLETE" || "${STACK_STATUS}" == "UPDATE_COMPLETE" ]]; then
    log_success "Stack status: ${STACK_STATUS}"
  else
    log_error "Stack status: ${STACK_STATUS}"
    return 1
  fi

  # Check ECS cluster
  local CLUSTER_STATUS
  CLUSTER_STATUS=$(aws ecs describe-clusters \
    --clusters "${PROJECT_NAME}-${ENVIRONMENT}" \
    --region "${REGION}" \
    --query 'clusters[0].status' \
    --output text 2>/dev/null || echo "NOT_FOUND")

  if [[ "${CLUSTER_STATUS}" == "ACTIVE" ]]; then
    log_success "ECS Cluster: ACTIVE"
  else
    log_warn "ECS Cluster: ${CLUSTER_STATUS}"
  fi

  # Check Lambda functions
  for FUNC in "pipeline-runner" "approval-gate"; do
    local FUNC_NAME="${PROJECT_NAME}-${ENVIRONMENT}-${FUNC}"
    local FUNC_STATE
    FUNC_STATE=$(aws lambda get-function \
      --function-name "${FUNC_NAME}" \
      --region "${REGION}" \
      --query 'Configuration.State' \
      --output text 2>/dev/null || echo "NOT_FOUND")

    if [[ "${FUNC_STATE}" == "Active" ]]; then
      log_success "Lambda ${FUNC}: Active"
    else
      log_warn "Lambda ${FUNC}: ${FUNC_STATE}"
    fi
  done

  # Check DynamoDB tables
  for TABLE in "audit-trail" "pipeline-state" "checkpoints"; do
    local TABLE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-${TABLE}"
    local TABLE_STATUS
    TABLE_STATUS=$(aws dynamodb describe-table \
      --table-name "${TABLE_NAME}" \
      --region "${REGION}" \
      --query 'Table.TableStatus' \
      --output text 2>/dev/null || echo "NOT_FOUND")

    if [[ "${TABLE_STATUS}" == "ACTIVE" ]]; then
      log_success "DynamoDB ${TABLE}: ACTIVE"
    else
      log_warn "DynamoDB ${TABLE}: ${TABLE_STATUS}"
    fi
  done

  # Check SQS queues
  for QUEUE in "agent-dispatch" "approval-requests" "agent-responses" "dead-letter"; do
    local QUEUE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-${QUEUE}"
    if aws sqs get-queue-url --queue-name "${QUEUE_NAME}" --region "${REGION}" &>/dev/null; then
      log_success "SQS ${QUEUE}: OK"
    else
      log_warn "SQS ${QUEUE}: NOT_FOUND"
    fi
  done

  echo ""
  log_success "Health check complete."
}

# ==============================================================================
# Main
# ==============================================================================

main() {
  echo ""
  echo "==========================================="
  echo "  ForgeSquad AWS Deployment"
  echo "  Environment: ${ENVIRONMENT}"
  echo "  Region: ${REGION}"
  echo "  Stack: ${STACK_NAME}"
  echo "==========================================="
  echo ""

  check_prerequisites

  if [[ "${DESTROY}" == "true" ]]; then
    destroy_stack
    exit 0
  fi

  package_lambdas
  validate_template

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_success "Dry run complete. Template is valid. No resources deployed."
    exit 0
  fi

  deploy_stack
  post_deployment
  health_check

  echo ""
  log_success "ForgeSquad deployment complete!"
  echo ""
}

main
