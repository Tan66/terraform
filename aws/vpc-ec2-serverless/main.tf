# module "vpc" {
#   source = "../modules/vpc"
# }

# module "ecs" {
#   source = "../modules/ecs-with-ec2"
#   vpc_zone_identifier = module.vpc.public_subnet_ids
#   ec2_security_groups = [module.vpc.allow_all_security_group_id]
# }

# module "ec2" {
#   depends_on = [
#     module.vpc
#   ]
#   count = var.apache_ec2_server_create ? 1 : 0
#   source                 = "../modules/ec2"
#   subnet_id              = module.vpc.public_subnet_ids[1]
#   vpc_security_group_ids = [module.vpc.allow_all_security_group_id]
#   # user_data              = file("init.sh")
# }

# module "rest_api" {

#   for_each = var.rest_api_config

#   source = "../modules/rest_api"
#   name = var.rest_api_config[each.key].name
#   types = var.rest_api_config[each.key].types
#   endpoint_ids = var.rest_api_config[each.key].endpoint_ids # uncomment for regional or edge
#   # endpoint_ids = [module.vpc.vpc_endpoint_id]
# }


#####################################################################################

## alb

resource "aws_lb" "this" {
  name                       = "test-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["sg-0514c74aa9d2ff8f6"]
  subnets                    = ["subnet-0347d508cc6569b3a", "subnet-034f764acdc6adfc5"]
  enable_http2               = false
  enable_deletion_protection = false

  access_logs {
    bucket  = "alb-logs"
    prefix  = "test-lb"
    enabled = false
  }

  tags = {
    "env" = "dev"
  }
}

output "alb_dns" {
  value = aws_lb.this.dns_name
}

# ## alb target group

resource "aws_lb_target_group" "this" {
  name        = "test-ecs-tg"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = "vpc-029e094861e3ca8a6"
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
  tags = {
    "env" = "dev"
  }
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  tags = {
    "env" = "dev"
  }
}


# ##############################################################################
# ## asg
module "ecs_asg" {
  source = "../modules/asg_ecs"

  for_each = var.asg_ecs_config
  create   = var.asg_ecs_config[each.key].create
  # asg ecs ec2 instance profile
  asg_ecs_instance_profile_name = var.asg_ecs_config[each.key].iam_role.asg_ecs_instance_profile_name
  asg_ecs_iam_role_name         = var.asg_ecs_config[each.key].iam_role.asg_ecs_iam_role_name

  # asg
  ec2_ecs_optimised_ami_name = var.asg_ecs_config[each.key].asg.aws_ami.name

  aws_launch_template_name                   = var.asg_ecs_config[each.key].asg.aws_launch_template.name
  aws_launch_template_instance_type          = var.asg_ecs_config[each.key].asg.aws_launch_template.instance_type
  aws_launch_template_key_name               = var.asg_ecs_config[each.key].asg.aws_launch_template.key_name
  aws_launch_template_vpc_security_group_ids = var.asg_ecs_config[each.key].asg.security_group_ids
  aws_launch_template_monitoring_enabled     = var.asg_ecs_config[each.key].asg.aws_launch_template.monitoring.enabled
  aws_launch_template_tags                   = var.asg_ecs_config[each.key].asg.aws_launch_template.tags
  ecs_cluster_name                           = var.asg_ecs_config[each.key].asg.aws_launch_template.ecs_cluster_name

  aws_autoscaling_group_name                = var.asg_ecs_config[each.key].asg.aws_autoscaling_group.name
  aws_autoscaling_group_desired_capacity    = var.asg_ecs_config[each.key].asg.aws_autoscaling_group.desired_capacity
  aws_autoscaling_group_min_size            = var.asg_ecs_config[each.key].asg.aws_autoscaling_group.min_size
  aws_autoscaling_group_max_size            = var.asg_ecs_config[each.key].asg.aws_autoscaling_group.max_size
  aws_autoscaling_group_vpc_zone_identifier = var.asg_ecs_config[each.key].asg.subnet_ids
}

output "asg_ecs_arn" {
  value = module.ecs_asg["asg1"].asg_arn
}


# ecs

module "ecs" {
  source = "../modules/ecs_external"

  for_each = var.ecs_config

  create                         = var.ecs_config[each.key].create
  cluster_name                   = var.ecs_config[each.key].cluster_name
  cluster_settings               = var.ecs_config[each.key].cluster_settings
  cluster_configuration          = var.ecs_config[each.key].cluster_configuration
  fargate_capacity_providers     = var.ecs_config[each.key].fargate_capacity_providers
  autoscaling_capacity_providers = var.ecs_config[each.key].autoscaling_capacity_providers
  tags                           = var.ecs_config[each.key].tags
}

module "ecs_task_definition" {
  source = "../modules/ecs_task_definition"

  for_each = var.ecs_task_definition_config

  create                   = var.ecs_task_definition_config[each.key].create
  family                   = var.ecs_task_definition_config[each.key].family
  container_definitions    = var.ecs_task_definition_config[each.key].container_definitions
  requires_compatibilities = var.ecs_task_definition_config[each.key].requires_compatibilities
  task_role_arn            = var.ecs_task_definition_config[each.key].task_role_arn
  task_execution_role_arn  = var.ecs_task_definition_config[each.key].task_execution_role_arn
  volume                   = var.ecs_task_definition_config[each.key].volume
  tags                     = var.ecs_task_definition_config[each.key].tags
}

output "apache_task_definition_arn" {
  value = module.ecs_task_definition["td1"].task_definition_arn
}

module "ecs_service" {
  source = "../modules/ecs_service"

  depends_on = [
    module.ecs
  ]

  for_each = var.ecs_service_config

  create                         = var.ecs_service_config[each.key].create
  name                           = var.ecs_service_config[each.key].name
  cluster                        = var.ecs_service_config[each.key].cluster
  task_definition                = var.ecs_service_config[each.key].task_definition
  desired_count                  = var.ecs_service_config[each.key].desired_count
  enable_execute_command         = var.ecs_service_config[each.key].enable_execute_command
  force_new_deployment           = var.ecs_service_config[each.key].force_new_deployment
  launch_type                    = var.ecs_service_config[each.key].launch_type
  scheduling_strategy            = var.ecs_service_config[each.key].scheduling_strategy
  load_balancer_target_group_arn = var.ecs_service_config[each.key].load_balancer.target_group_arn
  load_balancer_container_name   = var.ecs_service_config[each.key].load_balancer.container_name
  load_balancer_container_port   = var.ecs_service_config[each.key].load_balancer.container_port
  iam_role                       = var.ecs_service_config[each.key].iam_role
  tags                           = var.ecs_service_config[each.key].tags
}
