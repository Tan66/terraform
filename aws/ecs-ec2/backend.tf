terraform {
  backend "s3" {
    bucket = "tanveer-demo-terraform-state-backend"
    key    = "ecs/terraform.tfstate"
    region = "us-east-1"
  }
}