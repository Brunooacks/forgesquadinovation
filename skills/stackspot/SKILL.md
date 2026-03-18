---
name: "StackSpot"
description: "Cloud infrastructure platform for IaC templates and environment provisioning"
type: tool
version: "1.0.0"
category: infrastructure
agents: [dev-backend, architect]
---

# StackSpot — Cloud Infrastructure Platform

StackSpot provides Infrastructure as Code (IaC) templates, cloud stacks, and environment provisioning.

## When to Use StackSpot

- **Infrastructure provisioning**: Create cloud environments (dev, staging, prod)
- **IaC templates**: Generate Terraform/CloudFormation/Pulumi templates
- **Stack composition**: Combine pre-built stacks for common architectures
- **Environment parity**: Ensure consistent configs across environments
- **Cloud migration**: Generate infrastructure for migration projects

## Integration Pattern

When the Architect or Dev Backend needs infrastructure:

1. **Define requirements**: Specify cloud provider, services needed, scaling requirements
2. **Select stacks**: Choose from StackSpot's catalog of pre-built stacks
3. **Customize**: Adjust parameters (instance sizes, regions, networking)
4. **Generate IaC**: Export as Terraform/CloudFormation templates
5. **Apply**: Provision infrastructure through CI/CD pipeline

## Best Practices

- Always use IaC — no manual cloud console changes
- Tag all resources for cost allocation and ownership
- Use separate accounts/subscriptions per environment
- Enable encryption at rest and in transit by default
- Configure auto-scaling based on actual load patterns
- Use StackSpot's compliance checks before deploying

## Architecture Patterns Available

- **API Backend**: API Gateway + Lambda/ECS + RDS/DynamoDB
- **Web Application**: CloudFront + S3 + ECS + RDS
- **Event-Driven**: SNS/SQS + Lambda + DynamoDB Streams
- **Data Pipeline**: Kinesis/Kafka + Lambda + S3 + Athena
