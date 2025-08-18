terraform {
    backend "s3" {
        bucket         = "meirk-eks-bucket"
        key            = "env/dev/terraform.tfstate"
        region         = "us-east-1"
        encrypt        = true
        dynamodb_table = "my-eks-terraform-lock-table"
      
    }
}