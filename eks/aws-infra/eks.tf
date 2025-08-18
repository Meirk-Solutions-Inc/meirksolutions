module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.17"

  cluster_name        = var.cluster_name
  cluster_version     = var.kubernetes_version
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  # Small baseline NG; Karpenter handles most scaling
  eks_managed_node_groups = {
    baseline = {
      ami_type       = "AL2_x86_64"
      instance_types = var.node_instance_types

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      labels = { role = "baseline" }
      tags   = var.tags
    }
  }

  tags = var.tags
}