bucket         = "my-terraform-state-bucket-ec2"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-lock"
encrypt        = true
