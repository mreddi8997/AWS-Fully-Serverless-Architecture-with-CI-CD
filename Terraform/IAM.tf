resource "aws_iam_policy" "S3_policy" {
  name        = "WebAppS3"
  description = "Policy for accessing S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.s3_bucket.arn}",
          "${aws_s3_bucket.s3_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "WebAppRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Updated for standard RDS instance

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "rds_iam_auth_policy" {
  name        = "rds_iam_auth_policy"
  description = "Allows IAM Database Authentication to RDS instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:us-east-2:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.mysql-db.resource_id}/${aws_db_instance.mysql-db.username}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_rds_secret_policy" {
  name_prefix = "LambdaRdsSecretPolicy-"

  # Define permissions for accessing the db secret in AWS Secrets Manager
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ],
        Effect   = "Allow",
        Resource = aws_db_instance.mysql-db.master_user_secret[0].arn
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = aws_db_instance.mysql-db.master_user_secret[0].kms_key_id
      }
    ],
  })
}

resource "aws_iam_policy" "lambda_eni_policy" {
  name        = "eni_policy"
  description = "Policy to access EC2 ENI in VPC"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "role_attachment" {
  for_each = {
    "s3" : aws_iam_policy.S3_policy.arn,
    "rds" : aws_iam_policy.rds_iam_auth_policy.arn,
    "eni" : aws_iam_policy.lambda_eni_policy.arn,
    "secret" : aws_iam_policy.lambda_rds_secret_policy.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.lambda_role.name
}
