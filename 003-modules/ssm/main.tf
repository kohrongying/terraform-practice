// create custom iam instance profile for session manager
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "ec2.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test" {
  role = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

output "iam_instance_profile" {
  value = aws_iam_instance_profile.ssm_profile.name
}