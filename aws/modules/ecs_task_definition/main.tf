resource "aws_ecs_task_definition" "this" {
  count                 = var.create ? 1 : 0
  family                = var.family
  container_definitions = jsonencode(var.container_definitions)

  # EC2 or FARGATE
  requires_compatibilities = var.requires_compatibilities

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.task_execution_role_arn
  tags               = var.tags
}

## refer https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html