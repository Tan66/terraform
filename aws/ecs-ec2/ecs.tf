module "ecs_cluster" {
    source = "../modules/ecs_cluster"

    # ECS cluster details
    ecs_cluster_name = "demo-tanveer-ecs-2"
}