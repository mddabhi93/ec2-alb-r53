# Dev infrastructure with Terraform, ALB, Route 53, and SSM

This repository contains a modular Terraform setup for a dev environment that provisions:

- one EC2 instance in a private subnet
- one Application Load Balancer in public subnets
- optional Route 53 alias record
- SSM/Session Manager connectivity through IAM and VPC endpoints
- optional HTTPS listener using an ACM certificate ARN

## Structure

- environments/dev: environment-specific entrypoint for dev
- modules/networking: VPC, subnets, route tables, VPC endpoints
- modules/security: security groups for ALB and EC2
- modules/iam: IAM role and instance profile for SSM
- modules/compute: EC2 instance
- modules/alb: ALB, target group, listeners
- modules/dns: Route 53 record

## Usage

From the dev environment directory:

```bash
terraform init -backend=false
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

For remote state, configure an S3 backend using the provided backend.hcl file:

```bash
terraform init -backend-config=backend.hcl
```

## GitHub Actions

A workflow is available at .github/workflows/terraform.yml for:

- role-based AWS authentication using GitHub OIDC

- terraform fmt check
- terraform validate
- terraform plan on pull requests
- terraform apply on pushes to main

## Notes

- Replace the placeholder IAM role ARN in the workflow with your real GitHub OIDC role.
- Replace the backend bucket name in backend.hcl with your own state bucket.
- Set create_route53_record and acm_certificate_arn in terraform.tfvars when needed.
