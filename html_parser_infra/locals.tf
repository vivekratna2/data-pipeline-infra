locals {
  tags = {
    created_by = "terraform"
  }
  aws_ecr_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com"
}