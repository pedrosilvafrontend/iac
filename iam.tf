resource "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = ["cf23df2207d99a74fbe169e3eba035e633b65d94"]

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "tf-role" {
  name = "tf-role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRoleWithWebIdentity",
        Principal : {
          Federated : aws_iam_openid_connect_provider.oidc-git.arn
        },
        Condition : {
          StringEquals : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          StringLike : {
            "token.actions.githubusercontent.com:sub" : "repo:pedrosilvafrontend/iac:*"
          }
        }
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}



resource "aws_iam_role_policy" "tf-permission" {
  name = "tf-permission"
  role = aws_iam_role.tf-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Statement1"
        Action   = "ecr:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid      = "Statement2"
        Action   = "iam:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid      = "Statement3"
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "build.apprunner.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role_policy_attachment" "app-runner-ecr-read-only" {
  role       = aws_iam_role.app-runner-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRoleWithWebIdentity",
        Principal : {
          Federated : aws_iam_openid_connect_provider.oidc-git.arn
        },
        Condition : {
          StringEquals : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          StringLike : {
            "token.actions.githubusercontent.com:sub" : "repo:pedrosilvafrontend/sige:*"
          }
        }
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role_policy" "ecr-app-permission" {
  name = "ecr-app-permission"
  role = aws_iam_role.ecr-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Statement1"
        Action   = "apprunner:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Statement2"
        Action = [
          "iam:PassRole",
          "iam:CreateServiceLinkedRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid    = "Statement3"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      }
    ]
  })
}
