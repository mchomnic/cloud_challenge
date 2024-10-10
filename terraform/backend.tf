terraform {
  backend "s3" {
    bucket         = "webapp-terraform-state"
    key            = "terraform/state/dev.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    # dynamodb_table = "WebApp-TerraformLocks-dev"  # Uncomment this line to enable DynamoDB table for locking
  }
}

