# Data of ECS optimised AMI

data "aws_ami" "amazon_linux_ecs_optimized" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20220304-x86_64-ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "ecs_ec2_launch_configuration" {
  name = "lt-ecsec2launchconfiguration"
  image_id = data.aws_ami.amazon_linux_ecs_optimized.id
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "ecs_ec2_asg" {
  name = "${var.ecs_cluster_name}-asg"
  desired_capacity = 1
  min_size = 1
  max_size = 1
  vpc_zone_identifier = ["subnet-028f8ae0fb0968eca"]
  launch_configuration = aws_launch_configuration.ecs_ec2_launch_configuration.id
}

# resource "aws_ecs_cluster" "demo-ecs-cluster" {
#   name = var.ecs_cluster_name
# }