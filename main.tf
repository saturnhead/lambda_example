provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "hello.py"
  output_path = "hello.zip"
}

resource "aws_lambda_function" "hello_world_lambda" {
  function_name = "hello_world_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "hello.lambda_handler"
  runtime       = "python3.8"
  filename      = data.archive_file.lambda.output_path
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/hello_world_lambda"
  retention_in_days = 14
}