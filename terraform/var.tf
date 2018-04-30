variable "access_key" {}
variable "secret_key" {}

variable "aws_region" {
  default     = "eu-west-2"
  description = "Region in which to deploy the cluster"
}
