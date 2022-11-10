variable "subnet_id" {
  type        = string
  default     = ""
  description = "description"
}

variable "vpc_security_group_ids" {
  type        = list(any)
  default     = []
  description = "description"
}

variable "user_data" {
  type        = string
  default     = ""
  description = "description"
}
