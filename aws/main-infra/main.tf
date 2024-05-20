module "ecr" {
  source = "../modules/ecr"

  for_each = var.ecr_config

  repository_name = var.ecr_config[each.key].repository_name
  force_delete = var.ecr_config[each.key].force_delete
  image_tag_mutability = var.ecr_config[each.key].image_tag_mutability
  scan_on_push = var.ecr_config[each.key].scan_on_push
  tags =  var.ecr_config[each.key].tags
}
