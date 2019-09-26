/**
 * # tf-aws-cloudwatch-check-http
 * 
 * A Terraform module that does blackbox monitoring one or more http(s) endpoints
 *
 * Gives you per endpoint
 *
 * - A rule to monitor the endpoint and the configured rate
 * - Alarms for both status code and response time
 * 
 *
 * ## Contributing
 *
 * Ensure any variables you add have a type and a description.
 * This README is generated with [terraform-docs](https://github.com/segmentio/terraform-docs):
 *
 * `terraform-docs md . > README.md`
 *
 * ## Example Usage
 *
 * ```hcl 
 * module "http_check" {
 *   source = "git::ssh://git@gitlab.com/russell.whelan/tf-aws-cloudwatch-check-http.git"
 *   checks = [
 *     {
 *       "name" = "Google"
 *       "url" = "https://www.google.com"
 *       "rate" = "1 minute"
 *       "threshold" = "0.5"
 *       "valid_status_codes" = "200,301,301"
 *     }
 *   ]
 * }
 * ```
 *
 * The map for each check can have the following parameters:
 * 
 * - name
 * - url
 * - rate
 * - threshold (Relating to repsonse time)
 * - valid_return_codes
 * - ok_action (optional)
 * - insufficient_data_action (optional)
 * - alarm_action (optional)
 *
 * ## To Do / Know Issues
 * 
 */

resource "aws_cloudwatch_event_rule" "rule_http_check" {
  count = "${length(var.checks)}"
  name = "${lookup(var.checks[count.index],"name")}"
  description = "HTTP Check Rule for ${lookup(var.checks[count.index], "url")}"
  schedule_expression = "rate(${lookup(var.checks[count.index],"rate")})"
}

resource "aws_cloudwatch_event_target" "event_target_http_check" {
  count = "${length(var.checks)}"
  target_id = "${lookup(var.checks[count.index],"name")}"
  rule = "${element(aws_cloudwatch_event_rule.rule_http_check.*.name, count.index)}"
  arn = "${module.lambda.function_arn}"

  input = <<JSON
{
  "url": "${lookup(var.checks[count.index],"url")}",
  "valid_status_codes": "${lookup(var.checks[count.index], "valid_status_codes")}"
}
JSON
}

resource "aws_cloudwatch_metric_alarm" "alarm_http_check_response" {
  count = "${length(var.checks)}"
  alarm_name = "response-${lookup(var.checks[count.index], "name")}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 3
  threshold = "${lookup(var.checks[count.index], "threshold")}"
  metric_name = "WebResponseTime"
  namespace = "HTTP Checks"
  
  dimensions = {
    "URL" = "${lookup(var.checks[count.index], "url")}"
  }
  
  statistic  = "Maximum"
  period = "60"
}

resource "aws_cloudwatch_metric_alarm" "alarm_http_check_status" {
  count = "${length(var.checks)}"
  alarm_name = "status-${lookup(var.checks[count.index], "name")}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 3
  threshold = "1"
  metric_name = "WebStatus"
  namespace = "HTTP Checks"
  
  dimensions = {
    "URL" = "${lookup(var.checks[count.index], "url")}"
  }

  ok_actions = "${list(lookup(var.checks[count.index], "ok_action",""))}"  
  insufficient_data_actions= "${compact(list(lookup(var.checks[count.index], "insufficient_data_action","")))}"  
  alarm_actions = "${compact(list(lookup(var.checks[count.index], "alarm_action","")))}"  
  
  
  statistic  = "Maximum"
  period = "60"
}