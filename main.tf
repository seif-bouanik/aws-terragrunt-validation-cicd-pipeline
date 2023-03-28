terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56"
    }
  }
}
provider "aws" {
  profile = var.AWS_PROFILE
  region  = var.AWS_REGION
  default_tags {
    tags = {
      Project    = var.PROJECT_NAME
      Deployment = var.DEPLOYMENT
      Author     = var.AUTHOR
    }
  }
}