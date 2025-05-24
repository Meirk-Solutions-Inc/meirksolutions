provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "54.145.129.179:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "c8c42d10-c9f9-3dec-eef5-782c5bdb9549"
      secret_id = "05f4e959-8f28-9230-8168-8143e5a57927"
    }
  }
}

/*data "vault_kv_secret_v2" "example" {
  mount = "secret" // change it according to your mount
  name  = "test-secret" // change it according to your secret
}

resource "aws_instance" "my_instance" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  tags = {
    Name = "test"
    Secret = data.vault_kv_secret_v2.example.data["foo"]
  }
}*/
