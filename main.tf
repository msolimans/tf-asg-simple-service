locals {
    bucket = "webserver-s3-us-east-1"
}

module "vpc" {
  name = "vpc"
  source = "./modules/vpc"

  cidr =  "10.20.0.0/16"
  private_subnets = ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"] #4096 IPs
  public_subnets  = ["10.20.96.0/20", "10.20.112.0/20", "10.20.128.0/20"]
  nat_gateway = {
    enabled = true,
    single_az = false
  }
}

module "s3" {
    source = "./modules/s3"
    name = local.bucket
    dir = "files" //files to be uploaded to s3
}
