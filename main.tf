# Add all Terraform configurations here,

#  TO DO Terraform State Backend strore in S3 using DynamoDB Lock

provider "aws" {
  region  = "eu-west-2"
  profile = "default"
}
terraform {
  required_version = "1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}