variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
  default     = "meirk-micro-cluster"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.29"
  description = "Kubernetes version"
}

variable "node_instance_types" {
  type        = list(string)
  default     = ["t3.large"]
}

variable "admin_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the EKS public endpoint"
  default     = ["23.17.48.170/32"] # Replace with your admin IPs for better security
}
variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "tags" {
  type        = map(string)
  default     = { project = "micro-eks", env = "dev" }
}

variable "enable_karpenter" {
  type        = bool
  description = "Enable Karpenter provisioning and resources"
  default     = false
}

variable "enable_k8s_addons" {
  type        = bool
  description = "Enable EBS CSI, ALB, metrics"
  default     = false
}
