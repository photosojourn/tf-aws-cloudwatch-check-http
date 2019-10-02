data "aws_iam_policy_document" "lambda" {
  statement {
    sid = "1"

    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*"
    ]
  }

}

module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda?ref=v1.1.0"

  function_name                  = "http_check"
  description                    = "Completes HTTP chec for a given URL"
  handler                        = "lambda.lambda_handler"
  runtime                        = "python3.6"
  timeout                        = 300
  reserved_concurrent_executions = 1

  source_path = "${path.module}/lambda.py"

  policy     = {
      json = "${data.aws_iam_policy_document.lambda.json}"
  }

  vpc_config = "${var.vpc_config}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda.function_arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.rule_http_check.*.arn}"
}
