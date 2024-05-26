# module "ecr" {
#   source = "../modules/ecr"

#   for_each = var.ecr_config

#   repository_name = var.ecr_config[each.key].repository_name
#   force_delete = var.ecr_config[each.key].force_delete
#   image_tag_mutability = var.ecr_config[each.key].image_tag_mutability
#   scan_on_push = var.ecr_config[each.key].scan_on_push
#   tags =  var.ecr_config[each.key].tags
# }

## get latest ecs ami id

data "aws_ami" "example" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ecs-image-id" {
  value = data.aws_ami.example.image_id
}

output "ecs-ami-name" {
  value = data.aws_ami.example.name
}