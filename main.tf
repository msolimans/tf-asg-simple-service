locals {
    vpc_cidr = "10.20.0.0/16"
    bucket = "webserver-s3-us-east-1"
}

module "vpc" {
  name = "vpc"
  source = "./modules/vpc"

  cidr =  local.vpc_cidr  
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

module "service" {
  source = "./modules/service"
  keypair = "test"
#   azs = module.vpc.azs
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id =  module.vpc.id
  vpc_cidr = local.vpc_cidr
  bucket = local.bucket
  depends_on = [
    module.s3,
    module.vpc
  ]
}

output "dns" {  
    value = module.service.elb_dns_name
}

# # In case you want to save pem file to use for ssh - uncomment below resource
# resource "local_file" "ssh_key" {
#   filename = "file.pem"
#   # change permission to 400 (chmod 400 file.pem) as it will not work
#   content = module.webservers.keypair_private_key
# }
