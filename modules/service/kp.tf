//rsa private key
resource "tls_private_key" "this" {
  count = var.keypair == "" ? 0 : 1
  algorithm = "RSA"
}

//gen rsa public/private key
resource "aws_key_pair" "this" {
  count = var.keypair == "" ? 0 : 1
  key_name   = var.keypair
  public_key = tls_private_key.this[count.index].public_key_openssh
}
