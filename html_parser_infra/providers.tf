provider "aws" {
  region = "us-east-1"
  shared_credentials_files = [
  "~/.aws/credentials"]
  profile = "gbd-user"
}

provider "docker" {
  registry_auth {
    address  = local.aws_ecr_url
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}