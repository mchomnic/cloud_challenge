provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region based on environment"
  type        = string
}

variable "environment" {
  description = "Environment type DEV/PROD based on the deployment"
  type        = string
}

variable "spell_checker_lambda" {
  description = "Spell Checker Lambda function name"
  type        = string
  default     = "spellcheck-lambda"
}
