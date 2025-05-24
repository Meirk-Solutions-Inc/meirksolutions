provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://54.145.129.179:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "c8c42d10-c9f9-3dec-eef5-782c5bdb9549"   # Replace with your role_id
      # If you have a secret_id, uncomment the next line and replace with your secret_id
      secret_id = "fefd87ec-0607-9bed-75d5-c9cc94357b34" # Replace with your secret_id
      # If you are using a token, you can use the following line instead
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

data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test-secret"
}

resource "aws_instance" "vault-test-instance" {
   ami         = "ami-084568db4383264d4"
   instance_type = "t2.micro"

   tags = {
     Name = "TestvaultApp"
     secret = data.vault_kv_secret_v2.example.data["admin"]
}
}