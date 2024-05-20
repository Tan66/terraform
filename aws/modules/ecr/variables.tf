variable "repository_name" {
  type        = string
  default     = ""
  description = "repository_name"
}

variable "image_tag_mutability" {
  type        = string
  default     = ""
}

variable "scan_on_push" {
  type        = bool
  default     = false
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "force_delete" {
  type        = bool
  default     = false
}
