# EKS Terraform Starter with Karpenter + ALB Ingress

## Prerequisites
- AWS CLI configured with permissions for VPC/EKS/IAM/EC2/SSM
- Terraform >= 1.5
- kubectl
- (Recommended) An S3 bucket + DynamoDB table for remote state

## Steps
1. **Clone this folder** (`infra/`) and edit `backend.tf` bucket/table, and `terraform.tfvars` values.
2. **Init**
   ```bash
   cd infra
   terraform init