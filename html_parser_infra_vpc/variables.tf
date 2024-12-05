variable "public_subnet_cidr" {
  type        = list(any)
  description = "Private CIDR"
  default     = ["10.51.8.0/22", "10.51.16.0/22"]

}

variable "private_subnet_cidr" {
  type        = list(any)
  description = "Private CIDR"
  default     = ["10.51.20.0/22", "10.51.28.0/22"]
}

variable "aws_region" {
  type  = string
  default = "us-east-1"
}
