data "terraform_remote_state" "etl_vpc" {
  backend = "s3"
  config = {
    bucket         = "gbd-airflow-tf-state"
    key            = "etl-vpc/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-locking"
    profile        = "gbd-user"
  }
}