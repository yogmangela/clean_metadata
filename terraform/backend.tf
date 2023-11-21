terraform {
  backend "s3" {
    bucket         = "infrastructure-terraform-state-backend"
    key            = "clean-metadata/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform_state"
  }
}