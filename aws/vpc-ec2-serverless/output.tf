# vpc

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value      = module.vpc.public_subnet_ids
  sensitive  = false
  depends_on = []
}

# output "private_subnets" {
#   value      = module.vpc.private_subnet_ids
#   sensitive  = false
#   depends_on = []
# }

# output "security_group_id" {
#   value = module.vpc.security_group_id
#   #   sensitive   = true
#   description = "description"
#   depends_on  = []
# }

# output "vpc_endpoint_id" {
#     value = module.vpc.vpc_endpoint_id
# }

# ec2
output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
  #   sensitive   = true
  description = "description"
  depends_on  = []
}
