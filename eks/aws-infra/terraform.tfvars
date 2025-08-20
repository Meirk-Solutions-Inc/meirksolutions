/*
cluster_name       = "demo-eks"
region             = "ca-central-1"
kubernetes_version = "1.29"
node_instance_types = ["t3.large"]
desired_size = 2
min_size     = 2
max_size     = 4
admin_cidrs = ["<your_public_ip>/32"]

tags = {
  owner  = "muiz"
  env    = "dev"
  app    = "demo"
  region = "us-east-1"
}
*/
