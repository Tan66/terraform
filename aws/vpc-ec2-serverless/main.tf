module "vpc" {
  source = "../modules/vpc"
}

# module "ecs" {
#   source = "../modules/ecs-with-ec2"
#   vpc_zone_identifier = module.vpc.public_subnet_ids
#   ec2_security_groups = [module.vpc.allow_all_security_group_id]
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
  name               = "test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.vpc.allow_all_security_group_id]
  subnets            = [for subnet in module.vpc.public_subnet_ids : subnet]
  enable_http2 = false
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

## alb target group

resource "aws_lb_target_group" "this" {
  name     = "test-ecs-tg"
  port     = 80
  target_type = "instance"
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    enabled = true
    healthy_threshold = 3
    interval = 30
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 3
  }
  tags = {
    "env" = "dev"
  }
}

resource "aws_lb_listener" "thi" {
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

data "aws_iam_policy_document" "this" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
          type = "Service"
          identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "this" {
  name = "ecs-ec2-agent-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
      {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
              "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "this" {
  name = "ecs-ec2-agent-ip"
  role = aws_iam_role.this.name
}

data "aws_ami" "amazon_linux_ecs_optimized" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20221118-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "this" {
  name = "ecs-ec2"

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  image_id = data.aws_ami.amazon_linux_ecs_optimized.id
  instance_type = "t2.micro"
  key_name = "ec2mumbai"

  monitoring {
    enabled = false
  }

  vpc_security_group_ids = [module.vpc.allow_all_security_group_id]

  tags = {
    "env" = "dev"
  }
  user_data =  base64encode("#!/bin/bash\necho ECS_CLUSTER=ecs-ec2 >> /etc/ecs/ecs.config;")
}

resource "aws_autoscaling_group" "ecs_ec2_asg" {
  name                 = "test-asg"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = module.vpc.public_subnet_ids
  # launch_configuration = aws_launch_configuration.ecs_ec2_launch_configuration.id
  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }
  
  tag {
    key = "AmazonECSManaged"
    value = ""
    propagate_at_launch = true
  }
}

# asg
module "ecs_ec2" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-ec2"

  cluster_settings = {
      name = "containerInsights"
      value = "disabled"
  }

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn = aws_autoscaling_group.ecs_ec2_asg.arn
      managed_termination_protection  = "DISABLED"

      managed_scaling =  {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 100
        base = 1
      }
    }
  }
}

## task definition
## refer https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html
resource "aws_ecs_task_definition" "this" {
  family = "test"
  container_definitions = jsonencode(
    [
      {
        name = "nginx"
        image = "nginx"
        cpu = 0
        memory = 300
        memoryReservation = 256
        essential = true
        environment = []
        mountPoints = []
        privilaged = false
        secrets = []
        volumesFrom = []
        portMappings = [
          {
            containerPort = 80
            hostPort = 0
            protocol = "tcp"
          }
        ]

      }
    ]
  )

  # EC2 or FARGATE
  requires_compatibilities = [
    "EC2"
  ]
  
  tags = {
    "env" = "dev"
  }
}

## ecs service

data "aws_iam_role" "ecs_service_role" {
  name = "AWSServiceRoleForECS"
}

resource "aws_ecs_service" "this" {
  name = "nginx"
  cluster = module.ecs_ec2.cluster_name
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = 1
  enable_execute_command = false
  force_new_deployment = true
  launch_type = "EC2" # EC2, FARGATE, EXTERNAL
  scheduling_strategy = "REPLICA" # REPLICA or DAEMON
  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name = "nginx"
    container_port = 80
  }
  iam_role = data.aws_iam_role.ecs_service_role.arn
  tags = {
    "env" = "dev"
  }
  
}









#########################
# not all feature available in launch configuration
# resource "aws_launch_configuration" "ecs_ec2_launch_configuration" {
#   name          = "lt-ecsec2launchconfiguration"
#   image_id      = data.aws_ami.amazon_linux_ecs_optimized.id
#   instance_type = "t2.micro"
#   iam_instance_profile = aws_iam_instance_profile.this.name
#   security_groups = [module.vpc.allow_all_security_group_id]
#   key_name = "ec2mumbai"
#   user_data = "#!/bin/bash\necho ECS_CLUSTER=ecs-ec2 >> /etc/ecs/ecs.config;"
# }