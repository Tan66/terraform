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

# data "aws_iam_policy_document" "this" {
#     statement {
#         actions = ["sts:AssumeRole"]

#         principals {
#           type = "Service"
#           identifiers = ["ec2.amazonaws.com"]
#         }
#     }
# }

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

# resource "aws_autoscaling_group" "ecs_ec2_asg" {
#   name                 = "test-asg"
#   desired_capacity     = 1
#   min_size             = 1
#   max_size             = 1
#   vpc_zone_identifier  = module.vpc.public_subnet_ids
#   launch_configuration = aws_launch_configuration.ecs_ec2_launch_configuration.id
# }

# # asg
# module "ecs_ec2" {
#   source = "terraform-aws-modules/ecs/aws"

#   cluster_name = "ecs-ec2"

#   cluster_settings = {
#       name = "containerInsights"
#       value = "disabled"
#   }

#   autoscaling_capacity_providers = {
#     one = {
#       auto_scaling_group_arn = aws_autoscaling_group.ecs_ec2_asg.arn
#       managed_termination_protection  = "DISABLED"

#       managed_scaling =  {
#         maximum_scaling_step_size = 5
#         minimum_scaling_step_size = 1
#         status                    = "ENABLED"
#         target_capacity           = 60
#       }

#       default_capacity_provider_strategy = {
#         weight = 100
#         base = 1
#       }
#     }
#   }
# }