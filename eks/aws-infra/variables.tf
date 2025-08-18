variable "cluster_name" {
  type        = string
  description = "Meirk-micro-cluster"
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