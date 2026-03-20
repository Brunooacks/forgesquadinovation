# ==============================================================================
# ForgeSquad — Terraform Infrastructure
# Multi-Agent Orchestration Framework on AWS
# ==============================================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }

  backend "s3" {
    bucket         = "forgesquad-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "forgesquad-terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ==============================================================================
# Variaveis / Variables
# ==============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "forgesquad"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "notification_email" {
  description = "Email for checkpoint notifications"
  type        = string
}

variable "agent_image_uri" {
  description = "ECR image URI for the agent container"
  type        = string
  default     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/forgesquad-agent:latest"
}

variable "domain_name" {
  description = "Custom domain name (optional)"
  type        = string
  default     = ""
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  is_prod     = var.environment == "prod"
  is_not_dev  = var.environment != "dev"

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]
  isolated_subnets = ["10.0.20.0/24", "10.0.21.0/24"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# ==============================================================================
# KMS — Chave de Criptografia / Encryption Key
# ==============================================================================

resource "aws_kms_key" "main" {
  description             = "${local.name_prefix} master encryption key"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowServiceAccess"
        Effect = "Allow"
        Principal = {
          Service = [
            "logs.amazonaws.com",
            "sqs.amazonaws.com",
            "sns.amazonaws.com",
            "s3.amazonaws.com",
            "dynamodb.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${local.name_prefix}"
  target_key_id = aws_kms_key.main.key_id
}

# ==============================================================================
# VPC — Rede / Networking
# ==============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${local.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.name_prefix}-igw" }
}

# --- Public Subnets ---
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${local.name_prefix}-public-${count.index == 0 ? "a" : "b"}" }
}

# --- Private Subnets ---
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.azs[count.index]

  tags = { Name = "${local.name_prefix}-private-${count.index == 0 ? "a" : "b"}" }
}

# --- Isolated Subnets ---
resource "aws_subnet" "isolated" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.isolated_subnets[count.index]
  availability_zone = local.azs[count.index]

  tags = { Name = "${local.name_prefix}-isolated-${count.index == 0 ? "a" : "b"}" }
}

# --- NAT Gateways ---
resource "aws_eip" "nat" {
  count  = local.is_prod ? 2 : 1
  domain = "vpc"
  tags   = { Name = "${local.name_prefix}-nat-eip-${count.index}" }
}

resource "aws_nat_gateway" "main" {
  count         = local.is_prod ? 2 : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags       = { Name = "${local.name_prefix}-nat-${count.index}" }
  depends_on = [aws_internet_gateway.main]
}

# --- Route Tables ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.name_prefix}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.name_prefix}-private-rt-${count.index}" }
}

resource "aws_route" "private_nat" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[local.is_prod ? count.index : 0].id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# --- Security Groups ---
resource "aws_security_group" "ecs" {
  name_prefix = "${local.name_prefix}-ecs-"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }

  tags = { Name = "${local.name_prefix}-ecs-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${local.name_prefix}-vpce-"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description     = "HTTPS from ECS tasks"
  }

  tags = { Name = "${local.name_prefix}-vpce-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

# --- VPC Endpoints ---
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
  tags              = { Name = "${local.name_prefix}-s3-endpoint" }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
  tags              = { Name = "${local.name_prefix}-dynamodb-endpoint" }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.isolated[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  tags                = { Name = "${local.name_prefix}-sqs-endpoint" }
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.sns"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.isolated[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  tags                = { Name = "${local.name_prefix}-sns-endpoint" }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.isolated[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  tags                = { Name = "${local.name_prefix}-sm-endpoint" }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.isolated[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  tags                = { Name = "${local.name_prefix}-logs-endpoint" }
}

# ==============================================================================
# S3 — Armazenamento de Artefatos / Artifact Storage
# ==============================================================================

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${local.name_prefix}-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = !local.is_prod
  tags          = { Name = "${local.name_prefix}-artifacts" }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "artifacts_deny_http" {
  bucket = aws_s3_bucket.artifacts.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyNonHttps"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.artifacts.arn,
        "${aws_s3_bucket.artifacts.arn}/*"
      ]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
  }

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"
    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket" "reports" {
  bucket        = "${local.name_prefix}-reports-${data.aws_caller_identity.current.account_id}"
  force_destroy = !local.is_prod
  tags          = { Name = "${local.name_prefix}-reports" }
}

resource "aws_s3_bucket_versioning" "reports" {
  bucket = aws_s3_bucket.reports.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "reports" {
  bucket                  = aws_s3_bucket.reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==============================================================================
# DynamoDB — Trilha de Auditoria e Estado / Audit Trail and State
# ==============================================================================

resource "aws_dynamodb_table" "audit_trail" {
  name         = "${local.name_prefix}-audit-trail"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "pipelineId"
  range_key = "timestamp"

  attribute {
    name = "pipelineId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "agentRole"
    type = "S"
  }

  global_secondary_index {
    name            = "agent-role-index"
    hash_key        = "agentRole"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.main.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = { Name = "${local.name_prefix}-audit-trail" }
}

resource "aws_dynamodb_table" "pipeline_state" {
  name         = "${local.name_prefix}-pipeline-state"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "pipelineId"

  attribute {
    name = "pipelineId"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.main.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = { Name = "${local.name_prefix}-pipeline-state" }
}

resource "aws_dynamodb_table" "checkpoints" {
  name         = "${local.name_prefix}-checkpoints"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "checkpointId"

  attribute {
    name = "checkpointId"
    type = "S"
  }

  attribute {
    name = "pipelineId"
    type = "S"
  }

  global_secondary_index {
    name            = "pipeline-index"
    hash_key        = "pipelineId"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.main.arn
  }

  tags = { Name = "${local.name_prefix}-checkpoints" }
}

# ==============================================================================
# SQS — Filas de Comunicacao / Communication Queues
# ==============================================================================

resource "aws_sqs_queue" "dead_letter" {
  name                      = "${local.name_prefix}-dead-letter"
  message_retention_seconds = 1209600
  kms_master_key_id         = aws_kms_key.main.id

  tags = { Name = "${local.name_prefix}-dead-letter" }
}

resource "aws_sqs_queue" "agent_dispatch" {
  name                       = "${local.name_prefix}-agent-dispatch"
  visibility_timeout_seconds = 900
  message_retention_seconds  = 1209600
  kms_master_key_id          = aws_kms_key.main.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = 3
  })

  tags = { Name = "${local.name_prefix}-agent-dispatch" }
}

resource "aws_sqs_queue" "approval_requests" {
  name                       = "${local.name_prefix}-approval-requests"
  visibility_timeout_seconds = 43200
  message_retention_seconds  = 1209600
  kms_master_key_id          = aws_kms_key.main.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = 3
  })

  tags = { Name = "${local.name_prefix}-approval-requests" }
}

resource "aws_sqs_queue" "agent_responses" {
  name                       = "${local.name_prefix}-agent-responses"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600
  kms_master_key_id          = aws_kms_key.main.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = 3
  })

  tags = { Name = "${local.name_prefix}-agent-responses" }
}

# ==============================================================================
# SNS — Notificacoes / Notifications
# ==============================================================================

resource "aws_sns_topic" "checkpoint_notify" {
  name              = "${local.name_prefix}-checkpoint-notify"
  kms_master_key_id = aws_kms_key.main.id
  tags              = { Name = "${local.name_prefix}-checkpoint-notify" }
}

resource "aws_sns_topic_subscription" "checkpoint_email" {
  topic_arn = aws_sns_topic.checkpoint_notify.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_sns_topic" "pipeline_complete" {
  name              = "${local.name_prefix}-pipeline-complete"
  kms_master_key_id = aws_kms_key.main.id
  tags              = { Name = "${local.name_prefix}-pipeline-complete" }
}

resource "aws_sns_topic" "error_alerts" {
  name              = "${local.name_prefix}-error-alerts"
  kms_master_key_id = aws_kms_key.main.id
  tags              = { Name = "${local.name_prefix}-error-alerts" }
}

resource "aws_sns_topic_subscription" "error_email" {
  topic_arn = aws_sns_topic.error_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# ==============================================================================
# Cognito — Autenticacao / Authentication
# ==============================================================================

resource "aws_cognito_user_pool" "main" {
  name = "${local.name_prefix}-users"

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]
  mfa_configuration        = local.is_prod ? "ON" : "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 1
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = false
  }

  schema {
    name                = "squad_role"
    attribute_data_type = "String"
    required            = false
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 50
    }
  }

  tags = { Name = "${local.name_prefix}-user-pool" }
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "${local.name_prefix}-app"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true

  callback_urls = [
    var.domain_name != "" ? "https://${var.domain_name}/callback" : "http://localhost:3000/callback"
  ]

  logout_urls = [
    var.domain_name != "" ? "https://${var.domain_name}/logout" : "http://localhost:3000/logout"
  ]

  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_group" "groups" {
  for_each = {
    admin     = { description = "Full access to all ForgeSquad features", precedence = 0 }
    architect = { description = "Create squads, approve architecture decisions", precedence = 10 }
    developer = { description = "Run pipelines and approve code reviews", precedence = 20 }
    viewer    = { description = "Read-only access to reports and artifacts", precedence = 30 }
  }

  name         = each.key
  user_pool_id = aws_cognito_user_pool.main.id
  description  = each.value.description
  precedence   = each.value.precedence
}

# ==============================================================================
# ECS — Cluster e Execucao de Agentes / Agent Execution
# ==============================================================================

resource "aws_ecs_cluster" "main" {
  name = local.name_prefix

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.main.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_exec.name
        cloud_watch_encryption_enabled = true
      }
    }
  }

  tags = { Name = local.name_prefix }
}

resource "aws_cloudwatch_log_group" "ecs_exec" {
  name              = "/ecs/${local.name_prefix}/exec"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.main.arn
}

resource "aws_cloudwatch_log_group" "agents" {
  name              = "/ecs/${local.name_prefix}/agents"
  retention_in_days = local.is_prod ? 365 : 30
  kms_key_id        = aws_kms_key.main.arn
}

# --- IAM Roles for ECS ---
resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name_prefix}-agent-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_secrets" {
  name = "secrets-access"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/${var.environment}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = [aws_kms_key.main.arn]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-agent-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_permissions" {
  name = "agent-permissions"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.agent_dispatch.arn,
          aws_sqs_queue.agent_responses.arn,
          aws_sqs_queue.approval_requests.arn
        ]
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Query"]
        Resource = [
          aws_dynamodb_table.audit_trail.arn,
          "${aws_dynamodb_table.audit_trail.arn}/index/*",
          aws_dynamodb_table.pipeline_state.arn
        ]
      },
      {
        Sid      = "KMSAccess"
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [aws_kms_key.main.arn]
      },
      {
        Sid      = "CloudWatchLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = ["${aws_cloudwatch_log_group.agents.arn}:*"]
      }
    ]
  })
}

# --- ECS Task Definition ---
resource "aws_ecs_task_definition" "agent" {
  family                   = "${local.name_prefix}-agent"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  ephemeral_storage {
    size_in_gib = 30
  }

  container_definitions = jsonencode([{
    name      = "agent"
    image     = var.agent_image_uri
    essential = true

    environment = [
      { name = "ENVIRONMENT", value = var.environment },
      { name = "PROJECT_NAME", value = var.project_name },
      { name = "AWS_REGION", value = var.aws_region },
      { name = "DISPATCH_QUEUE_URL", value = aws_sqs_queue.agent_dispatch.url },
      { name = "RESPONSE_QUEUE_URL", value = aws_sqs_queue.agent_responses.url },
      { name = "APPROVAL_QUEUE_URL", value = aws_sqs_queue.approval_requests.url },
      { name = "ARTIFACTS_BUCKET", value = aws_s3_bucket.artifacts.id },
      { name = "AUDIT_TABLE", value = aws_dynamodb_table.audit_trail.name },
      { name = "PIPELINE_STATE_TABLE", value = aws_dynamodb_table.pipeline_state.name },
      { name = "CHECKPOINT_TOPIC_ARN", value = aws_sns_topic.checkpoint_notify.arn },
      { name = "MODEL_TIER", value = "sonnet" }
    ]

    secrets = [
      {
        name      = "ANTHROPIC_API_KEY"
        valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/${var.environment}/anthropic-api-key"
      },
      {
        name      = "GITHUB_TOKEN"
        valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/${var.environment}/github-token"
      },
      {
        name      = "DEVIN_API_KEY"
        valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/${var.environment}/devin-api-key"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.agents.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "agent"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])

  tags = { Name = "${local.name_prefix}-agent" }
}

# ==============================================================================
# Lambda — Funcoes de Orquestracao / Orchestration Functions
# ==============================================================================

resource "aws_iam_role" "lambda" {
  name = "${local.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name = "forgesquad-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECSRunTask"
        Effect = "Allow"
        Action = ["ecs:RunTask", "ecs:StopTask", "ecs:DescribeTasks"]
        Resource = [
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task-definition/${local.name_prefix}-agent:*",
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task/${local.name_prefix}/*"
        ]
      },
      {
        Sid      = "ECSPassRole"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = [aws_iam_role.ecs_task_execution.arn, aws_iam_role.ecs_task.arn]
      },
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage", "sqs:ReceiveMessage",
          "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:GetQueueUrl"
        ]
        Resource = [
          aws_sqs_queue.agent_dispatch.arn,
          aws_sqs_queue.approval_requests.arn,
          aws_sqs_queue.agent_responses.arn
        ]
      },
      {
        Sid      = "SNSPublish"
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = [
          aws_sns_topic.checkpoint_notify.arn,
          aws_sns_topic.pipeline_complete.arn,
          aws_sns_topic.error_alerts.arn
        ]
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem", "dynamodb:GetItem",
          "dynamodb:UpdateItem", "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.audit_trail.arn,
          "${aws_dynamodb_table.audit_trail.arn}/index/*",
          aws_dynamodb_table.pipeline_state.arn,
          aws_dynamodb_table.checkpoints.arn,
          "${aws_dynamodb_table.checkpoints.arn}/index/*"
        ]
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*",
          aws_s3_bucket.reports.arn, "${aws_s3_bucket.reports.arn}/*"
        ]
      },
      {
        Sid      = "KMSAccess"
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [aws_kms_key.main.arn]
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "pipeline_runner" {
  name              = "/aws/lambda/${local.name_prefix}-pipeline-runner"
  retention_in_days = local.is_prod ? 365 : 30
  kms_key_id        = aws_kms_key.main.arn
}

resource "aws_lambda_function" "pipeline_runner" {
  function_name = "${local.name_prefix}-pipeline-runner"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  timeout       = 900
  memory_size   = 1024
  role          = aws_iam_role.lambda.arn
  filename      = "${path.module}/../lambda/pipeline-runner/pipeline-runner.zip"

  environment {
    variables = {
      ENVIRONMENT                = var.environment
      PROJECT_NAME               = var.project_name
      ECS_CLUSTER                = aws_ecs_cluster.main.name
      TASK_DEFINITION            = aws_ecs_task_definition.agent.arn
      DISPATCH_QUEUE_URL         = aws_sqs_queue.agent_dispatch.url
      RESPONSE_QUEUE_URL         = aws_sqs_queue.agent_responses.url
      APPROVAL_QUEUE_URL         = aws_sqs_queue.approval_requests.url
      ARTIFACTS_BUCKET           = aws_s3_bucket.artifacts.id
      AUDIT_TABLE                = aws_dynamodb_table.audit_trail.name
      PIPELINE_STATE_TABLE       = aws_dynamodb_table.pipeline_state.name
      CHECKPOINT_TABLE           = aws_dynamodb_table.checkpoints.name
      CHECKPOINT_TOPIC_ARN       = aws_sns_topic.checkpoint_notify.arn
      PIPELINE_COMPLETE_TOPIC_ARN = aws_sns_topic.pipeline_complete.arn
      ERROR_ALERTS_TOPIC_ARN     = aws_sns_topic.error_alerts.arn
      SUBNET_A                   = aws_subnet.private[0].id
      SUBNET_B                   = aws_subnet.private[1].id
      SECURITY_GROUP             = aws_security_group.ecs.id
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.ecs.id]
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [aws_cloudwatch_log_group.pipeline_runner]
  tags       = { Name = "${local.name_prefix}-pipeline-runner" }
}

resource "aws_cloudwatch_log_group" "approval_gate" {
  name              = "/aws/lambda/${local.name_prefix}-approval-gate"
  retention_in_days = local.is_prod ? 365 : 30
  kms_key_id        = aws_kms_key.main.arn
}

resource "aws_lambda_function" "approval_gate" {
  function_name = "${local.name_prefix}-approval-gate"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  timeout       = 30
  memory_size   = 256
  role          = aws_iam_role.lambda.arn
  filename      = "${path.module}/../lambda/approval-gate/approval-gate.zip"

  environment {
    variables = {
      ENVIRONMENT            = var.environment
      PROJECT_NAME           = var.project_name
      AUDIT_TABLE            = aws_dynamodb_table.audit_trail.name
      PIPELINE_STATE_TABLE   = aws_dynamodb_table.pipeline_state.name
      CHECKPOINT_TABLE       = aws_dynamodb_table.checkpoints.name
      DISPATCH_QUEUE_URL     = aws_sqs_queue.agent_dispatch.url
      ARTIFACTS_BUCKET       = aws_s3_bucket.artifacts.id
      PIPELINE_RUNNER_FUNCTION = "${local.name_prefix}-pipeline-runner"
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.ecs.id]
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [aws_cloudwatch_log_group.approval_gate]
  tags       = { Name = "${local.name_prefix}-approval-gate" }
}

# ==============================================================================
# API Gateway — Interface REST
# ==============================================================================

resource "aws_api_gateway_rest_api" "main" {
  name        = "${local.name_prefix}-api"
  description = "ForgeSquad Pipeline Orchestration API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = { Name = "${local.name_prefix}-api" }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "CognitoAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.main.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.main.arn]
}

# --- /pipeline ---
resource "aws_api_gateway_resource" "pipeline" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "pipeline"
}

resource "aws_api_gateway_method" "pipeline_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.pipeline.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "pipeline_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.pipeline.id
  http_method             = aws_api_gateway_method.pipeline_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.pipeline_runner.invoke_arn
}

resource "aws_lambda_permission" "pipeline_apigw" {
  function_name = aws_lambda_function.pipeline_runner.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/POST/pipeline"
}

# --- /approval ---
resource "aws_api_gateway_resource" "approval" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "approval"
}

resource "aws_api_gateway_method" "approval_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.approval.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "approval_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.approval.id
  http_method             = aws_api_gateway_method.approval_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.approval_gate.invoke_arn
}

resource "aws_lambda_permission" "approval_apigw" {
  function_name = aws_lambda_function.approval_gate.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/POST/approval"
}

# --- Deployment ---
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [
    aws_api_gateway_integration.pipeline_lambda,
    aws_api_gateway_integration.approval_lambda
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.main.id
  stage_name    = var.environment

  xray_tracing_enabled = true

  tags = { Name = "${local.name_prefix}-api-stage" }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
    logging_level          = "INFO"
    data_trace_enabled     = !local.is_prod
    metrics_enabled        = true
  }
}

# ==============================================================================
# WAF — Protecao da API / API Protection
# ==============================================================================

resource "aws_wafv2_web_acl" "main" {
  count = local.is_not_dev ? 1 : 0

  name  = "${local.name_prefix}-waf"
  scope = "REGIONAL"

  default_action { allow {} }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
  }

  rule {
    name     = "RateLimit"
    priority = 1
    action { block {} }
    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-rate-limit"
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-common-rules"
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-bad-inputs"
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 4
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-sqli"
    }
  }

  tags = { Name = "${local.name_prefix}-waf" }
}

resource "aws_wafv2_web_acl_association" "main" {
  count = local.is_not_dev ? 1 : 0

  resource_arn = aws_api_gateway_stage.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main[0].arn
}

# ==============================================================================
# CloudWatch — Monitoramento / Monitoring
# ==============================================================================

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${local.name_prefix}-dlq-messages"
  alarm_description   = "Messages in dead letter queue indicate processing failures"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.dead_letter.name
  }

  alarm_actions = [aws_sns_topic.error_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.name_prefix}-lambda-errors"
  alarm_description   = "Pipeline runner Lambda function errors"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = aws_lambda_function.pipeline_runner.function_name
  }

  alarm_actions = [aws_sns_topic.error_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "${local.name_prefix}-api-5xx"
  alarm_description   = "API Gateway 5xx errors"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 10
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.main.name
  }

  alarm_actions = [aws_sns_topic.error_alerts.arn]
}

# ==============================================================================
# Secrets Manager — Segredos / Secrets
# ==============================================================================

resource "aws_secretsmanager_secret" "anthropic_api_key" {
  name        = "${var.project_name}/${var.environment}/anthropic-api-key"
  description = "Anthropic API key for Claude model access"
  kms_key_id  = aws_kms_key.main.arn
  tags        = { Name = "${local.name_prefix}-anthropic-key" }
}

resource "aws_secretsmanager_secret" "github_token" {
  name        = "${var.project_name}/${var.environment}/github-token"
  description = "GitHub personal access token"
  kms_key_id  = aws_kms_key.main.arn
  tags        = { Name = "${local.name_prefix}-github-token" }
}

resource "aws_secretsmanager_secret" "devin_api_key" {
  name        = "${var.project_name}/${var.environment}/devin-api-key"
  description = "Devin API key for autonomous coding tasks"
  kms_key_id  = aws_kms_key.main.arn
  tags        = { Name = "${local.name_prefix}-devin-key" }
}

# ==============================================================================
# Saidas / Outputs
# ==============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.main.invoke_url}"
}

output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "artifacts_bucket" {
  description = "S3 artifacts bucket name"
  value       = aws_s3_bucket.artifacts.id
}

output "reports_bucket" {
  description = "S3 reports bucket name"
  value       = aws_s3_bucket.reports.id
}

output "audit_trail_table" {
  description = "DynamoDB audit trail table name"
  value       = aws_dynamodb_table.audit_trail.name
}

output "pipeline_state_table" {
  description = "DynamoDB pipeline state table name"
  value       = aws_dynamodb_table.pipeline_state.name
}

output "checkpoint_topic_arn" {
  description = "SNS checkpoint notification topic ARN"
  value       = aws_sns_topic.checkpoint_notify.arn
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.main.arn
}

output "pipeline_runner_arn" {
  description = "Pipeline Runner Lambda ARN"
  value       = aws_lambda_function.pipeline_runner.arn
}

output "approval_gate_arn" {
  description = "Approval Gate Lambda ARN"
  value       = aws_lambda_function.approval_gate.arn
}
