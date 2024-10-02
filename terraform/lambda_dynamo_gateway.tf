# Create a Lambda function that increments a DynamoDB item
resource "aws_dynamodb_table" "visitor_counter" {
  name         = "${var.environment}-WebVisitorCounter"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_dynamodb_role" {
  name = "${var.environment}_web_lambda_dynamodb_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach the policy that grants the Lambda function access to DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "${var.environment}_web_lambda_dynamodb_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:UpdateItem",
        "dynamodb:GetItem"
      ]
      Effect   = "Allow"
      Resource = aws_dynamodb_table.visitor_counter.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_dynamodb_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Archive file into lambda package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/lambda/"
  output_path = "${path.module}/lambda_package.zip"
}

resource "aws_lambda_function" "visitor_counter_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.environment}-WebVisitorCounterLambda"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_counter.name
    }
  }
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.environment}-VisitorCounterAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.lambda_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor_counter_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /increment"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "allow_apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.lambda_api.api_endpoint
}
