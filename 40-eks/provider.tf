terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58"
    }
  }
  backend "s3" {
    bucket = "chandu-reddy-s3-buckets"
    key    = "expense-dev-eks"
    region = "us-east-1"
    dynamodb_table = "chandureddy-prod"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}