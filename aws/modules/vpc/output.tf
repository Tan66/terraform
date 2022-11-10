output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnets.*.id
  sensitive   = false
  description = "description"
}

# output "private_subnet_ids" {
#   value       = aws_subnet.private_subnets.*.id
#   sensitive   = false
#   description = "description"
# }

# output "security_group_id" {
#   value = aws_security_group.lamda_sg.id
# }

output "ec2_security_group_id" {
  value = aws_security_group.allow.id
}

# output "vpc_endpoint_id" {
#     value = aws_vpc_endpoint.vpc_endpoint.id
# }