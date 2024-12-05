terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }
  required_version = ">= 1.2.0"
  backend "s3" {
    bucket         = "gbd-airflow-tf-state"
    key            = "etl-db/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-locking"
  }
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "gbd-user"
}