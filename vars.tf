variable "checks" {
  type        = "list"
  description = "A List of maps of endpoints to monitor"
}

variable "attach_vpc_config" {
  type        = "string"
  description = "Set this to true if using the vpc_config variable"
  default     = "false"
}

variable "vpc_config" {
  type        = "map"
  description = "Lambda VPC Config"
  default     = {}
}