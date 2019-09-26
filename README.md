# tf-aws-cloudwatch-check-http

A Terraform module that does blackbox monitoring one or more http(s) endpoints

Gives you per endpoint

- A rule to monitor the endpoint and the configured rate
- Alarms for both status code and response time


## Contributing

Ensure any variables you add have a type and a description.
This README is generated with [terraform-docs](https://github.com/segmentio/terraform-docs):

`terraform-docs md . > README.md`

## Example Usage

```hcl
module "http_check" {
  source = "git::ssh://git@gitlab.com/russell.whelan/tf-aws-cloudwatch-check-http.git"
  checks = [
    {
      "name" = "Google"
      "url" = "https://www.google.com"
      "rate" = "1 minute"
      "threshold" = "0.5"
      "valid_return_codes" = "200,301,301"
    }
  ]
}
```

The map for each check can have the following parameters:

- name
- url
- rate
- threshold (Relating to repsonse time)
- valid_return_codes
- ok_action (optional)
- insufficient_data_action (optional)
- alarm_action (optional)

## To Do / Know Issues


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attach\_vpc\_config | Set this to true if using the vpc_config variable | string | `false` | no |
| checks | A List of maps of endpoints to monitor | list | - | yes |
| vpc\_config | Lambda VPC Config | map | `<map>` | no |

