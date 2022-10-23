
#security group for ec2
resource "aws_security_group" "ec2-sg" {
  name = "terraform-ec2-sg"
  vpc_id      = var.vpc_id

  #lb to ec2 
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    security_groups = [aws_security_group.elb-sg.id]
  }

  //22 within vpc (thru bastion)
  ingress {
    from_port   = 22
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group for elb
resource "aws_security_group" "elb-sg" {
  name = "terraform-elb-sg"
  vpc_id      = var.vpc_id

  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}