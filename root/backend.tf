terraform {
  backend "s3" {
    bucket         = "sreproj-terraform-state-bucket"
    key            = "statefile.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"  # Optional for locking
    encrypt        = true
    profile        = "sre_terraform_user" 
  }
}