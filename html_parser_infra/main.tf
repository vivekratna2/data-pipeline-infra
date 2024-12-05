terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.27.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
  backend "s3" {
    bucket         = "gbd-airflow-tf-state"
    key            = "htmlparser/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-locking"
  }
}