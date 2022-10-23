resource "aws_elb" "this" {
  name               = "terraform-asg-elb"
  security_groups    = [aws_security_group.elb-sg.id]
  subnets            = var.public_subnet_ids

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 10 #faster detection of unhealthy instances 
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # Adding a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}