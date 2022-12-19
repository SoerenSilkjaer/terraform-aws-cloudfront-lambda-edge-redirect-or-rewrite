data aws_iam_policy_document assume_role_policy {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data aws_iam_policy_document role_policy {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "cloudwatch" {
  provider = aws.us-east-1
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 30
}

resource aws_iam_role lambda {
  provider = aws.us-east-1
  name               = local.project_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource aws_iam_role_policy cloudwatch {
  provider = aws.us-east-1
  name   = "cloudwatch"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.role_policy.json
}
