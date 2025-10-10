terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    bucket = "neccdc-2025-terraform-cornellcyber"
    key    = "regionals/black/terraform.tfstate"
    region = "us-east-2"

    profile = "neccdc-2025"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

provider "aws" {
  region = var.region

  profile = "neccdc-2025"

  default_tags {
    tags = {
      terraform = "true"
      path      = "terraform/regionals/environments/black"
    }
  }
}
