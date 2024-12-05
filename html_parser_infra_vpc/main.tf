terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
  required_version = ">= 1.2.0"
  backend "s3" {
    bucket = "gbd-airflow-tf-state"
    key    = "uat/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-east-1"
  shared_credentials_files = [
  "~/.aws/credentials"]
  profile = "gbd-user"
}