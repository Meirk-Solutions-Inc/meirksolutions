# EBS CSI Driver as EKS managed add-on
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = null
  tags                     = var.tags
}

# AWS Load Balancer Controller (Helm)
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"

  depends_on = [
    kubernetes_service_account.alb,
    aws_iam_role_policy_attachment.alb_attach,
    module.eks
  ]

    set { 
        name = "clusterName"
        value = module.eks.cluster_name 
    }
    set { 
        name = "serviceAccount.create" 
        value = "false" 
        }
    set { 
        name = "serviceAccount.name"
        value = "aws-load-balancer-controller" 
        }
}

# Metrics Server (Helm)
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.1"

  depends_on = [module.eks]

  set { 
    name = "args{0}" 
    value = "--kubelet-insecure-tls" 
    }
}