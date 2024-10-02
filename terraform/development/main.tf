provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region based on environment"
  type        = string
}

variable "environment" {
  description = "Environment type DEV/STAGE/PROD based on the deployment"
  type        = string
}
