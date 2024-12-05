terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }
  required_version = ">= 1.2.0"
  backend "s3" {
    bucket = "gbd-airflow-tf-state"
    key    = "etl-vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
  shared_credentials_files = [
  "/home/vrkansakar/.aws/credentials"]
  profile = "rtaws"
}