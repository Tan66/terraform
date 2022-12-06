resource "aws_ecs_cluster" "ecs_cluster" {
  name = "test_ecs_cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = null
      logging = "DEFAULT"   # NONE, DEFAULT, and OVERRIDE

      # set logging to OVERRIDE if log_configuration is supplied
    #   log_configuration {
    #     cloud_watch_encryption_enabled = false
    #     cloud_watch_log_group_name = "test_log_group"
    #     s3_bucket_name = "test"
    #     s3_bucket_encryption_enabled = false
    #     s3_key_prefix = "test_prefix"
    #   }
    }
  }

  setting {
    name  = "containerInsights"
    value = "disabled" # enabled or disabled
  }

  tags = {
    "env" = "dev"
  }
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


resource "aws_launch_configuration" "ecs_ec2_launch_configuration" {
  name          = "lt-ecsec2launchconfiguration"
  image_id      = data.aws_ami.amazon_linux_ecs_optimized.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.this.name
  security_groups = var.ec2_security_groups
}

resource "aws_autoscaling_group" "ecs_ec2_asg" {
  name                 = "test-asg"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = var.vpc_zone_identifier
  launch_configuration = aws_launch_configuration.ecs_ec2_launch_configuration.id
}

resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  name = "test_cp"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_ec2_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      instance_warmup_period = null // default 300s
      maximum_scaling_step_size = null // 1 - 10000
      minimum_scaling_step_size = null // 1-10000
      status = "ENABLED" // asg managed by ECS is enabled
      target_capacity = null // 1-100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ec2_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ec2_capacity_provider.name]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider.name
  }
}

# Error: failed creating ECS Capacity Provider (test_cp): ClientException: The managed termination protection setting for the capacity provider is invalid. To enable managed termination protection for a capacity provider, the Auto Scaling group must have instance protection from scale in enabled.