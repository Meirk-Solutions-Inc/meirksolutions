output "cluster_name"         { value = module.eks.cluster_name }
output "cluster_endpoint"     { value = module.eks.cluster_endpoint }
output "oidc_provider_arn"    { value = module.eks.oidc_provider_arn }
output "node_group_role_name" { value = try(module.eks.eks_managed_node_groups["baseline"].iam_role_name, null) }