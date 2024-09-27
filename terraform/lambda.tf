resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.environment}SpellCheckLambdaExecRole"
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

resource "aws_lambda_function" "spellcheck_lambda" {
  function_name = var.spell_checker_lambda
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.spellcheck.repository_url}:latest"

  # Specify the handler (lambda_function is the name of the file)
  handler       = "spell_checker.handler"
  memory_size   = 256
  timeout       = 300

  role = aws_iam_role.lambda_exec_role.arn
}


# Attach the policy to the Lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.spell_check_lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name        = "${var.environment}SpellCheckLambdaCloudwatchPolicy"
  description = "Policy for Lambda function to log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_custom_cloudwatch_policy_attachment" {
  name       = "${var.environment}SpellCheckLambdaCloudwatchPolicyAttachment"
  roles      = [aws_iam_role.spell_check_lambda_exec_role.name]
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
}
