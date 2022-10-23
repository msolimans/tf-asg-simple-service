output "elb_dns_name" {
  value       = aws_elb.this.dns_name
  description = "The domain name of the load balancer"
} 

output "keypair_public_key" {
  value = var.keypair == "" ? "": aws_key_pair.this[0].public_key
}

output "keypair_private_key" {
  value = var.keypair == "" ? "": tls_private_key.this[0].private_key_pem
}
