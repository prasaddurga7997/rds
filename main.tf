terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source = "./vpc"
  block1 = var.block1
  block2 = var.block2
  region = var.region
  ami = var.ami
  instancetype = var.instancetype
}