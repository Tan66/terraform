
data "aws_ami" "amazon_linux_ecs_optimized" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = var.ec2_ecs_optimised_ami_name
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "this" {

  depends_on = [
    aws_iam_instance_profile.this
  ]

  name = var.aws_launch_template_name

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  image_id      = data.aws_ami.amazon_linux_ecs_optimized.id
  instance_type = var.aws_launch_template_instance_type
  key_name      = var.aws_launch_template_key_name

  monitoring {
    enabled = var.aws_launch_template_monitoring_enabled
  }

  vpc_security_group_ids = var.aws_launch_template_vpc_security_group_ids

  tags      = var.aws_launch_template_tags
  user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config;")
}

resource "aws_autoscaling_group" "this" {

  count = var.create ? 1 : 0

  name                = var.aws_autoscaling_group_name
  desired_capacity    = var.aws_autoscaling_group_desired_capacity
  min_size            = var.aws_autoscaling_group_min_size
  max_size            = var.aws_autoscaling_group_max_size
  vpc_zone_identifier = var.aws_autoscaling_group_vpc_zone_identifier
  # launch_configuration = aws_launch_configuration.ecs_ec2_launch_configuration.id
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
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