# vpc

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value      = module.vpc.public_subnet_ids
  sensitive  = false
  depends_on = []
}

output "private_subnets" {
  value      = module.vpc.private_subnet_ids
  sensitive  = false
  depends_on = []
}

output "security_group_id" {
  value = module.vpc.allow_all_security_group_id
  #   sensitive   = true
  description = "description"
  depends_on  = []
}

# output "vpc_endpoint_id" {
#     value = module.vpc.vpc_endpoint_id
# }

# ec2
# output "ec2_public_ip" {
#   value = var.apache_ec2_server_count ?  one(module.ec2).ec2_public_ip : null
#   #   sensitive   = true
#   description = "description"
#   depends_on  = []
# }

# rest api
# output "rest_api_id" {
#   # value = module.rest_api.rest_api_id
#   value = {
#     for k, v in module.rest_api : k => v
#   }
# }

## ECS

output "asg_ecs_arn" {
  value = module.ecs_asg["asg1"].asg_arn
}

## ecs task definition

output "apache_task_definition_arn" {
  value = module.ecs_task_definition["td1"].task_definition_arn
}