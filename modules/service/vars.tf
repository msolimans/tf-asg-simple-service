variable "server_port" {
  description = "The port the web server will be listening"
  type        = number
  default     = 80
}

variable "elb_port" {
  description = "The port the elb will be listening"
  type        = number
  default     = 80
} 

////////////
//ASG 
//what to launch 
variable "ami_id"{
    description = "ami id"
    default = "ami-09d3b3274b6c5d4aa"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default = "t3.micro" 
}

//launch capacity 
variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
  default = 1
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
  default = 2
}

variable "desired_capacity" {
  description = "The desired number of EC2 Instances in the ASG"
  type        = number
  default = 1
}

///////// 

variable "bucket" {
    description = "The name of the S3 bucket to grab the files from"
    type        = string
}

/////////

//generate key pair (don't use this in CI/CD pipelines)
variable "keypair" {
  description = "Generate a new key pair if it has value"
  type        = string 
  default     = ""
}

///////
//if provided, the route 53 will be updated with the DNS of the ELB
variable "route53_hosted_zone_id" {
  default = ""
}

variable "route53_record_name" {
    default = ""
}

///////
//for ec2 
variable "private_subnet_ids" {
    type = list(string)
    default = []
}

//for elb
variable "public_subnet_ids" {
    type = list(string)
    default = []
}

//where resources will exist 
variable "vpc_id" {
    type = string
}

//for opening 22 within vpc cidr only (in case we need to ssh into the ec2 thru bastion)
variable "vpc_cidr" {
    type = string
}