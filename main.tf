terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
  backend "s3" {
    bucket  = "tfstate"
    key     = "state/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "tfstate"
  force_destroy = true
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
  source = "./modules/eks"
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
  cluster_name = var.cluster_name
  retention_days = var.retention_days
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
}