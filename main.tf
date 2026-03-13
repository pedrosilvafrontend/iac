provider "aws" {
  region  = var.aws_region != "" ? var.aws_region : null
  profile = var.aws_profile != "" ? var.aws_profile : null
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.35.1"
    }
  }
  backend "s3" {
    bucket = "tride-iac"
    key    = "state/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_s3_bucket" "terraform-state" {
  bucket        = "tride-iac"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    IAC = "True"
  }
}

resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = "tride-iac"

  versioning_configuration {
    status = "Enabled"
  }
}