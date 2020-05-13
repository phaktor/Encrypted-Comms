//<editor-fold desc="Credentials">
provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  version = "2.57.0"
  region = "us-east-2"
}

module "VPC" {
  source = "./VPC"
  PublicSubnet = module.VPC.PublicSubnet
}

module "SECG" {
  source = "./SECG"
  VpcId = module.VPC.VpcID
}

module "IAM" {
  source = "./IAM"
}

module "EC2" {
  source = "./EC2"
  VpcId = module.VPC.VpcID
  PublicSubnet = module.VPC.PublicSubnet
  Matrix-SecG = module.SECG.Matrix-SecG
  SSM-Instance-Profile = module.IAM.SSM-Instance-Profile
}

