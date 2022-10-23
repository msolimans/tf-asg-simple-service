moved {
    from = aws_iam_instance_profile.profile
    to   = aws_iam_instance_profile.this
}
resource "aws_iam_instance_profile" "this" {
  name = "ec2-profile"
  role = aws_iam_role.role.name
  depends_on = [
    aws_iam_policy.policy
  ]
}

resource "aws_iam_role" "role" {
  name = "ec2-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  force_detach_policies = true
  depends_on = [
    aws_iam_policy.policy
 ]
}

resource "aws_iam_policy" "policy" {
  name        = "ec2-policy"
  description = "EC2 policy"

 # todo specific resource "Resource": "arn:aws:s3:::${var.bucket}/*"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

//attach policy to role 
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
  depends_on = [
  aws_iam_policy.policy
]
}
