locals {
  karpenter_namespace = "karpenter"
  karpenter_sa        = "karpenter"
  karpenter_version   = "0.37.0" # pin a recent stable
}

# IAM policy for Karpenter controller
resource "aws_iam_policy" "karpenter_controller" {
  name        = "${var.cluster_name}-KarpenterController"
  description = "Permissions for Karpenter controller to manage EC2 capacity"
  policy      = file("${path.module}/policies/karpenter-controller-policy.json")
}

data "aws_iam_policy_document" "karpenter_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.karpenter_namespace}:${local.karpenter_sa}"]
    }
  }
}

resource "aws_iam_role" "karpenter" {
  name               = "${var.cluster_name}-karpenter"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "karpenter_attach" {
  role       = aws_iam_role.karpenter.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

# Instance profile & role for worker nodes launched by Karpenter
resource "aws_iam_role" "karpenter_node" {
  name               = "${var.cluster_name}-karpenter-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  role       = aws_iam_role.karpenter_node.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "karpenter_node" {
  name = "${var.cluster_name}-karpenter-node"
  role = aws_iam_role.karpenter_node.name
}

# Namespace + SA for Karpenter
resource "kubernetes_namespace" "karpenter" {
  count = var.enable_karpenter ? 1 : 0
  metadata { name = local.karpenter_namespace }
}

resource "kubernetes_service_account" "karpenter" {
  count = var.enable_karpenter ? 1 : 0
  metadata {
    name      = local.karpenter_sa
    namespace = local.karpenter_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter.arn
    }
  }
  automount_service_account_token = true
  depends_on = [kubernetes_namespace.karpenter]
}

# Install Karpenter via Helm (OCI repo)
resource "helm_release" "karpenter" {
  count      = var.enable_karpenter ? 1 : 0
  name       = "karpenter"
  namespace  = local.karpenter_namespace
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = local.karpenter_version

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.karpenter_attach
  ]

  set {
  name  = "settings.clusterName"
  value = module.eks.cluster_name
}
set {
  name  = "settings.clusterEndpoint"
  value = module.eks.cluster_endpoint
}
set {
  name  = "serviceAccount.create"
  value = "false"
}
set {
  name  = "serviceAccount.name"
  value = local.karpenter_sa
}
}

# Karpenter CRDs (EC2NodeClass + NodePool)
resource "kubernetes_manifest" "ec2nodeclass" {
  count = var.enable_karpenter ? 1 : 0
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1beta1"
    kind       = "EC2NodeClass"
    metadata = { name = "default" }
    spec = {
      amiFamily      = "AL2"
      role           = aws_iam_role.karpenter_node.name
      instanceProfile = aws_iam_instance_profile.karpenter_node.name
      subnetSelectorTerms = [{ tags = { "karpenter.sh/discovery" = var.cluster_name } }]
      securityGroupSelectorTerms = [{
        tags = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
      }]
    }
  }
  depends_on = [helm_release.karpenter]
}

resource "kubernetes_manifest" "nodepool" {
  count = var.enable_karpenter ? 1 : 0
  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = { name = "general" }
    spec = {
      template = {
        spec = {
          nodeClassRef = { name = kubernetes_manifest.ec2nodeclass[0].object.metadata.name }
          requirements = [
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = ["t3","m6i","c6i"] },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
            { key = "topology.kubernetes.io/zone", operator = "In",
              values = ["${var.region}a","${var.region}b","${var.region}c"] }  # <— fixed
          ]
        }
      }
      disruption = { consolidationPolicy = "WhenUnderutilized" }
      limits     = { cpu = "2000" }
    }
  }
  depends_on = [kubernetes_manifest.ec2nodeclass]
}