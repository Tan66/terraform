# module "vpc" {
#   source = "../modules/vpc"
# }

# module "ec2" {
#   depends_on = [
#     module.vpc
#   ]
#   count = var.apache_ec2_server_count ? 1 : 0
#   source                 = "../modules/ec2"
#   subnet_id              = module.vpc.public_subnet_ids[1]
#   vpc_security_group_ids = [module.vpc.ec2_security_group_id]
#   user_data              = file("init.sh")
# }

module "rest_api" {

  for_each = var.rest_api_config

  source = "../modules/rest_api"
  name = var.rest_api_config[each.key].name
  types = var.rest_api_config[each.key].types
  endpoint_ids = var.rest_api_config[each.key].endpoint_ids # uncomment for regional or edge
  # endpoint_ids = [module.vpc.vpc_endpoint_id]
}