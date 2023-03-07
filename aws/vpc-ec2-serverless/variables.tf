# ec2
variable "apache_ec2_server_create" {
  type = bool
}


# rest api
# variable "rest_api_types" {
#     type = list
# }

# variable "rest_api_endpoint_ids" {
#     type = list
# }

variable "rest_api_config" {}

variable "asg_ecs_config" {

}

variable "ecs_config" {

}

variable "ecs_task_definition_config" {

}

variable "ecs_service_config" {

}