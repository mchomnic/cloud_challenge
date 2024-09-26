variable "aws_region" {
  description = "AWS region based on environment"
  type        = string
}

variable "environment" {
  description = "Environment type DEV/PROD based on the deployment"
  type        = string
}

provider "aws" {
  region = var.aws_region
}