resource "aws_iam_role" "ecs_instance" {
  name = "${var.prefix}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-ecs-instance-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.prefix}-ecs-instance-profile"

  role = aws_iam_role.ecs_instance.name
}


resource "aws_iam_role" "ecs_task_role" {
  name = "${var.prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-ecs-task-role"
    }
  )
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "secret_manager" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "secret_manager_task" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
}

resource "aws_iam_policy" "env_file_read" {
  name = "${var.prefix}-env-file-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnvFileReadObjectActions",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
        ]
        Resource = ["${var.env_bucket_arn}/*"]
      },
      {
        Sid      = "ListEnvBucket",
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = [var.env_bucket_arn]
      }
    ]
  })
}

resource "aws_iam_policy" "app_storage" {
  name = "${var.prefix}-app-storage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ApplicationReadDelete",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = ["${var.app_storage_bucket_arn}/*"]
      },
      {
        Sid      = "ListAppStorageBucket",
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = [var.app_storage_bucket_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_env_read" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.env_file_read.arn
}

resource "aws_iam_role_policy_attachment" "task_app_storage" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.app_storage.arn
}


resource "aws_iam_role_policy_attachment" "task_exec_env_read" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.env_file_read.arn

}


resource "aws_iam_role" "github_deploy" {
  name = "${var.prefix}-github-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.github_oidc_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "${var.github_repo}"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_deploy" {
  name = "${var.prefix}-github-deploy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage"
        ]

        Resource = var.ecr_repo_arn
      },

      {
        Effect = "Allow"

        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:UpdateService"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeClusters"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = [
          aws_iam_role.ecs_task_role.arn,
          aws_iam_role.ecs_task_execution_role.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_deploy" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = aws_iam_policy.github_deploy.arn
}