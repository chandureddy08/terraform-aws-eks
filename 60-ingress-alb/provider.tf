terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.48.0"
    } 
  }
  backend "s3" {
    bucket = "chandu-reddy-s3-buckets"
    key = "expence-dev-ingress"
    region = "us-east-1"
    dynamodb_table = "chandureddy-prod"
  }
}
  provider "aws"{
    region = "us-east-1"
  }