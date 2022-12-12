resource "aws_ecs_task_definition" "this" {
  count                 = var.create ? 1 : 0
  family                = var.family
  container_definitions = jsonencode(var.container_definitions)

  # EC2 or FARGATE
  requires_compatibilities = var.requires_compatibilities

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.task_execution_role_arn

  dynamic "volume" {
    for_each = var.volume == null || var.volume == {} ? [] : [var.volume]

    content {
      name = volume.value.name

      host_path = try(volume.value.host_path, null)

      dynamic "docker_volume_configuration" {
        for_each = try([volume.value.docker_volume_configuration], [])
        content {
          autoprovision = try(docker_volume_configuration.autoprovision, null)
          driver = try(docker_volume_configuration.driver, null)
          driver_opts = try(docker_volume_configuration.driver_opts, null)
          labels = try(docker_volume_configuration.labels, null)
          scope = try(docker_volume_configuration.scope, null)
        }
      }

      dynamic "efs_volume_configuration" {
        # for_each = try([volume.value.efs_volume_configuration], [])
        for_each = volume.value.efs_volume_configuration == null || volume.value.efs_volume_configuration == {} ? [] : [volume.value.efs_volume_configuration]
        content {
          file_system_id = try(efs_volume_configuration.file_system_id, null)
          root_directory = try(efs_volume_configuration.root_directory, null)
          transit_encryption = try(efs_volume_configuration.transit_encryption, null)
          transit_encryption_port = try(efs_volume_configuration.transit_encryption_port, null)
          authorization_config {
            access_point_id = try(efs_volume_configuration.authorization_config.access_point_id, null)
            iam = try(efs_volume_configuration.authorization_config.iam, null)
          }
        }
      }

      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = volume.value.fsx_windows_file_server_volume_configuration == null || volume.value.fsx_windows_file_server_volume_configuration == {} ? [] : [volume.value.fsx_windows_file_server_volume_configuration]
        content {
          file_system_id = try(fsx_windows_file_server_volume_configuration.file_system_id, null)
          root_directory = try(fsx_windows_file_server_volume_configuration.root_directory, null)
          authorization_config {
            credentials_parameter = try(fsx_windows_file_server_volume_configuration.authorization_config.credentials_parameter, null)
            domain = try(fsx_windows_file_server_volume_configuration.authorization_config.domain, null)
          }
        }
      }
    }
  }

  tags               = var.tags
}

## refer https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html