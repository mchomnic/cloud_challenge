terraform {
  backend "s3" {
    bucket  = "web-one-page-state"
    key     = "terraform.tfstate"
    encrypt = true
    region  = "eu-central-1"
    # dynamodb_table = "WebApp-TerraformLocks-dev"  # Uncomment this line to enable DynamoDB table for locking
  }
}
