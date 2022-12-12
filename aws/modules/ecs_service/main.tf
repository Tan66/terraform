resource "aws_ecs_service" "this" {
  count                  = var.create ? 1 : 0
  name                   = var.name
  cluster                = var.cluster
  task_definition        = var.task_definition
  desired_count          = var.desired_count
  enable_execute_command = var.enable_execute_command
  force_new_deployment   = var.force_new_deployment
  launch_type            = var.launch_type         # EC2, FARGATE, EXTERNAL
  scheduling_strategy    = var.scheduling_strategy # REPLICA or DAEMON
  load_balancer {
    target_group_arn = var.load_balancer_target_group_arn
    container_name   = var.load_balancer_container_name
    container_port   = var.load_balancer_container_port
  }
  iam_role = var.iam_role # required when using load balancer
  tags     = var.tags

}