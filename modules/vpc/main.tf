
locals {
  azs = (length(var.azs) > 1 ? var.azs : slice(data.aws_availability_zones.available.names, 0, max(length(var.private_subnets), length(var.public_subnets))))
}

# By default this module will provision EIP for NAT Gateway (https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#external-nat-gateway-ips)
module "this" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = var.name
  cidr = var.cidr #next vpc cidr 10.1.0.0/16 ..etc 

  # use this command to list all AZs in the region: aws ec2 describe-availability-zones --region (same as data.aws_availability_zones.available.names)
  azs             = local.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_ipv6 = false

  enable_dns_support   = true #enable dns support for vpc
  enable_dns_hostnames = true #enable dns hostnames for vpc 

  enable_nat_gateway     = var.nat_gateway.enabled #enable nat gateway
  single_nat_gateway     = var.nat_gateway.single_az #create nat gw in first subnet
  one_nat_gateway_per_az = (!var.nat_gateway.single_az)

  //use tags (helps a lot in identifying cost based on resources)
  public_subnet_tags = {
    Name = "${var.name}-public-subnet"
  }

  private_subnet_tags = {
    Name = "${var.name}-private-subnet"
  }

}
