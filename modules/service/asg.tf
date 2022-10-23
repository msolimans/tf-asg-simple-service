# to get what is the output of user-data 
# exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
resource "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    bucket = var.bucket 
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "ec2-lt"
  image_id      = var.ami_id #data.aws_ami.example.id 
  instance_type = var.instance_type

  update_default_version = true

  #todo add instance profile
  iam_instance_profile {
    # name = "test"
    # or
    arn = aws_iam_instance_profile.this.arn
  }

  key_name = var.keypair

  vpc_security_group_ids = [aws_security_group.ec2-sg.id] #for ec2 
  
  user_data = base64encode(template_file.user_data.rendered)

}

#####################

resource "aws_autoscaling_group" "this" {

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.private_subnet_ids

  health_check_grace_period = 90 // quicker (we can use warm_pool as well)

  lifecycle {
    create_before_destroy = true
  }

  
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity

  load_balancers    = [aws_elb.this.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}

##################################
# scalability based on cpu utilization
##################################

resource "aws_autoscaling_policy" "high-cpu" {
  name                   = "high-cpu-scaleup"
  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1 #add 1 instance
  #2 mins for cooldown
  cooldown    = "120"
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "high-cpu" {
  alarm_name          = "cpu-alarm-scaleup"
  alarm_description   = "cpu-alarm-scaleup"
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "60"
  #consecutive times
  evaluation_periods = "3"
  period             = "60"
  namespace          = "AWS/EC2"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.this.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.high-cpu.arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "low-cpu" {
  name                   = "cpu-alarm-scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"#remove 1 instance 
  cooldown               = "300" #5 mins 
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "low-cpu" {
  alarm_name          = "cpu-alarm-scaledown"
  alarm_description   = "cpu-alarm-scaledown"
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = "20"
  #consecutive times
  evaluation_periods = "3"
  # 3 mins + cooldown 5 mins = 8 mins
  period    = "180"
  namespace = "AWS/EC2"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.this.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.low-cpu.arn}"]
}