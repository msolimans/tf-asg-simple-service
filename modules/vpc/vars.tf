variable "name"{ 
  description = "Name of the VPC"
  default = "vpc"
}

variable "cidr" {
  type        = string
  description = "vpc cidr"
}

variable "private_subnets" {
  type        = list(string)
  description = "list of private subnets cidrs"
}

variable "public_subnets" {
  type        = list(string)
  description = "list of public subnets cidrs"
}

# if not set, use `data "aws_availability_zones" "available" {}` equivalent to `aws ec2 describe-availability-zones --region`
# only use 3 azs in the region
variable "azs" {
  type        = list(string)
  description = "list of availability zones, if not set it will fetch all azs in the max azs in region based on the number of subnets"
  default = []
}


variable "nat_gateway" {
  type = object({
    enabled   = bool
    single_az = bool
  })

  description = "Whether to enable nat gateway (defaults {enabled = true , single_az = true})"
  default = {
    enabled   = true
    single_az = true
  }
}
