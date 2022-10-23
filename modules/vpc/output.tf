output "id" {
  value = module.this.vpc_id
}

output "private_subnet_ids" {
  value = module.this.private_subnets
}

output "private_subnet_arns" {
  value = module.this.private_subnet_arns
}

output "public_subnet_ids" {
  value = module.this.public_subnets
}

output "public_subnet_arns" {
  value = module.this.public_subnet_arns
}

output "azs" {
  value = local.azs
}