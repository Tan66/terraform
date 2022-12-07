# reference: https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest

module "ecs" {

  source       = "terraform-aws-modules/ecs/aws"
  version      = "4.1.2"
  create       = var.create
  cluster_name = var.cluster_name

  cluster_settings               = var.cluster_settings
  cluster_configuration          = var.cluster_configuration
  fargate_capacity_providers     = var.fargate_capacity_providers
  autoscaling_capacity_providers = var.autoscaling_capacity_providers
  tags                           = var.tags
}