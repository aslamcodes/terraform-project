


resource "aws_iam_role" "ec2_rds_access" {
  name = "ec2_rds_access_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "rds_access_policy" {
  name        = "RDS_Access_Policy"
  description = "Policy for EC2 to access RDS resources"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBInstances",
          "rds:DescribeDBSnapshots",
          "rds:ListTagsForResource",
          "rds:Connect"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_rds_policy" {
  role       = aws_iam_role.ec2_rds_access.name
  policy_arn = aws_iam_policy.rds_access_policy.arn
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_rds_access.name
}
