data "aws_caller_identity" "current" {}
data "aws_ecr_authorization_token" "token" {}

data "aws_secretsmanager_secret" "by_name" {
  name = "htmlparser/${terraform.workspace}"
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.by_name.id
}

#data "terraform_remote_state" "htmlparser_webserver_output" {
#  backend = "s3"
#  config = {
#    bucket         = "gbd-airflow-tf-state"
#    key            = "env:/${terraform.workspace}/htmlparser/terraform.tfstate"
#    region         = "us-west-2"
#    dynamodb_table = "terraform-state-locking"
#    profile        = "gbd-user"
#    access_key     = ""
#    secret_key     = ""
#  }
# }