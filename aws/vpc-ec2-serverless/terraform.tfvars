# ec2
apache_ec2_server_create = false

# rest api
# rest_api_types = ["REGIONAL"]
# rest_api_endpoint_ids = [] # uncomment for regional or edget type

rest_api_config = {
  test1 = {
    name         = "test1"
    types        = ["REGIONAL"]
    endpoint_ids = []
  }

  test2 = {
    name         = "test2"
    types        = ["REGIONAL"]
    endpoint_ids = []
  }
}


## asg

asg_ecs_config = {
  asg1 = {
    create = true
    iam_role = {
      asg_ecs_instance_profile_name = "asg1-instance-profile"
      asg_ecs_iam_role_name         = "asg1-ecs-role"
    }

    asg = {
      aws_ami = {
        name = ["amzn2-ami-ecs-hvm-2.0.20221118-x86_64-ebs"]
      }

      aws_launch_template = {
        name          = "asg_ecs_lt"
        instance_type = "t2.micro"
        key_name      = "ec2mumbai"
        monitoring = {
          enabled = false
        }
        tags = {
          "env" = "dev"
        }
        ecs_cluster_name = "test_ecs" ## make sure to give the correct ecs cluster name
      }

      aws_autoscaling_group = {
        name             = "asg_ecs"
        desired_capacity = 1
        min_size         = 1
        max_size         = 1
      }

    }

  }
}

# ecs

ecs_config = {

  cluster1 = {
    create       = true # set create = false if asg not created/cluster not required
    cluster_name = "test_ecs"
    cluster_settings = {
      name  = "containerInsights"
      value = "disabled"
    }
    cluster_configuration      = null
    fargate_capacity_providers = {}
    autoscaling_capacity_providers = {
      one = {
        auto_scaling_group_arn         = "arn:aws:autoscaling:ap-south-1:270009541057:autoScalingGroup:93d114db-088b-4814-8e3c-3ca4e0c1fb9c:autoScalingGroupName/asg_ecs"
        managed_termination_protection = "DISABLED"

        # for autoscaling
        managed_scaling = {
          maximum_scaling_step_size = 5
          minimum_scaling_step_size = 1
          status                    = "ENABLED"
          target_capacity           = 60
        }

        default_capacity_provider_strategy = {
          weight = 100
          base   = 1
        }
      }
    }
    tags = {
      "env" = "dev"
    }
  }

  cluster2 = {
    create       = false # set create = false if asg not created/cluster not required
    cluster_name = "test_ecs_2"
    cluster_settings = {
      name  = "containerInsights"
      value = "disabled"
    }
    cluster_configuration      = null
    fargate_capacity_providers = {}
    autoscaling_capacity_providers = {
      one = {
        auto_scaling_group_arn         = "arn:aws:autoscaling:ap-south-1:270009541057:autoScalingGroup:4e615471-b351-45a9-85de-21965a5b2155:autoScalingGroupName/asg_ecs"
        managed_termination_protection = "DISABLED"

        # for autoscaling
        managed_scaling = {
          maximum_scaling_step_size = 5
          minimum_scaling_step_size = 1
          status                    = "ENABLED"
          target_capacity           = 60
        }

        default_capacity_provider_strategy = {
          weight = 100
          base   = 1
        }
      }
    }
    tags = {
      "env" = "dev"
    }
  }

}

# ecs task definition
ecs_task_definition_config = {
  td1 = {
    create = false
    family = "test"
    container_definitions = [
      {
        name              = "apache"
        image             = "ubuntu/apache2:2.4-22.04_beta"
        cpu               = 0
        memory            = 300
        memoryReservation = 256
        essential         = true
        environment       = []
        mountPoints       = []
        privilaged        = false
        secrets           = []
        volumesFrom       = []
        portMappings = [
          {
            containerPort = 80
            hostPort      = 0
            protocol      = "tcp"
          }
        ]

      }
    ]

    # EC2 or FARGATE
    requires_compatibilities = [
      "EC2"
    ]

    task_execution_role_arn = null
    task_role_arn           = null

    # volume = {
    #   name = "test"
    #   docker_volume_configuration = {}
    #   efs_volume_configuration = {}
    #   fsx_windows_file_server_volume_configuration = {}
    #   host_path = null
    # }

    volume = {}

    tags = {
      "env" = "dev"
    }
  }
}

## ecs_service
ecs_service_config = {
  svc1 = {
    create                 = false
    name                   = "apache2"
    cluster                = "test_ecs"                                                   ## make sure to give the correct ecs cluster name 
    task_definition        = "arn:aws:ecs:ap-south-1:270009541057:task-definition/test:4" ## arn
    desired_count          = 1
    enable_execute_command = false
    force_new_deployment   = true
    launch_type            = "EC2"     # EC2, FARGATE, EXTERNAL
    scheduling_strategy    = "REPLICA" # REPLICA or DAEMON
    load_balancer = {
      target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:270009541057:targetgroup/test-ecs-tg/bf8a37d77e4dcf9a"
      container_name   = "apache"
      container_port   = 80
    }
    iam_role = "arn:aws:iam::270009541057:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
    tags = {
      "env" = "dev"
    }
  }

}