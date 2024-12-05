resource "aws_security_group" "html_parser_sg" {
  name   = "AWS-GBD-html-parser-security-group-${terraform.workspace}"
  vpc_id = var.VPC_ID

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}