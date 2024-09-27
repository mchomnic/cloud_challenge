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
  function_name = "${var.environment}spellcheck-lambda"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.spellcheck.repository_url}:latest"
#   image_uri     = "<aws_account_id>.dkr.ecr.<region>.amazonaws.com/spellcheck-lambda:latest"

  # Specify the handler (lambda_function is the name of the file)
  handler       = "spell_checker.handler"
  memory_size   = 256
  timeout       = 300

  role = aws_iam_role.lambda_exec_role.arn
}
