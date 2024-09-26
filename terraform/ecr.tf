# Create ECR Repository
resource "aws_ecr_repository" "spellcheck" {
  name = "spellcheck-repo"
}

# Create IAM Role for ECR Access
resource "aws_iam_role" "ecr_push_role" {
  name = "ecr-push-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "ecs-tasks.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

# Policy for pushing to ECR
resource "aws_iam_role_policy" "ecr_push_policy" {
  role = aws_iam_role.ecr_push_role.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }]
  })
}

# Fetch ECR Login Credentials
data "aws_ecr_authorization_token" "ecr" {}

# Execute Docker build and push commands using local-exec
resource "null_resource" "build_and_push_image" {
  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.spellcheck.repository_url}
    docker build -t spellcheck .
    docker tag spellcheck:latest ${aws_ecr_repository.spellcheck.repository_url}:latest
    docker push ${aws_ecr_repository.spellcheck.repository_url}:latest
EOF

  }
}

# Output ECR Repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.spellcheck.repository_url
}
