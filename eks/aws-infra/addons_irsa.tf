locals {
  alb_controller_policy_name = "${var.cluster_name}-AWSLoadBalancerController"
  alb_service_account_name   = "aws-load-balancer-controller"
  alb_service_account_ns     = "kube-system"
}

resource "aws_iam_policy" "alb_controller" {
  name        = local.alb_controller_policy_name
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/aws-load-balancer-controller-policy.json")
}

data "aws_iam_policy_document" "alb_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.alb_service_account_ns}:${local.alb_service_account_name}"]
    }
  }
}

resource "aws_iam_role" "alb_irsa" {
  name               = "${var.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_irsa.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# Kubernetes SA annotated for IRSA (created prior to Helm release)
resource "kubernetes_service_account" "alb" {
  metadata {
    name      = local.alb_service_account_name
    namespace = local.alb_service_account_ns
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_irsa.arn
    }
    labels = { "app.kubernetes.io/name" = local.alb_service_account_name }
  }
  automount_service_account_token = true
}