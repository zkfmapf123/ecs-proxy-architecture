variable "env" {

}

variable "name" { 
    default = "squid"
}

resource "aws_security_group" "ecs_sg" {
  name = "${var.name}-ecs-sg"
  vpc_id = local.config.config.vpc_id
    description = "${var.name}-ecs-sg"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ecs" {
  source= "zkfmapf123/ecs-fargate/donggyu"

  is_use_alb = false
  ecr_attr = {
    is_enable = true
    name = var.name
    env = var.env
  }

  ecs_attr = {
    ecs_name = "${var.name}"
    ecs_env = var.env
    ecs_port = 8080
    ecs_hard_cpu = 256
    ecs_hard_mem = 512
    ecs_image_arn = "public.ecr.aws/f6h3f9t8/leedonggyu:latest"
    ecs_os_system = "LINUX"
    ecs_architecture = "ARM64"
    ecs_cluster = local.alb.ecs_cluster_name
  }

  ecs_health_check = {
    path = "/ping"
    port = 8080
    protocol = "HTTP"
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher  ="200-301"
    timeout = 5
    interval = 10
    grace_period = 30
    deregistration_delay = 30   
  }

  ecs_network_attr = {
    ecs_is_public_ip = false
    ecs_subnet_ids = local.config.config.was_subnet_ids
    ecs_sg_ids = [aws_security_group.ecs_sg.id]
    ecs_vpc_id = local.config.config.vpc_id
    ecs_443_listener_arn = local.alb.listener_443_arn
    ecs_priority = 100
    ecs_host_header = ["gateway.leedonggyu.com"]
  }

  execution_role_attr = {
    name = "${var.name}-execution-role"
    policy = {
        "Version" : "2012-10-17",
        "Statement" : [
            {
                "Effect" : "Allow",
                "Action" : ["logs:CreateLogGroup", "ecs:*","ecr:*"],
                "Resource" : "*"
            }
        ]
    }
  }

  task_role_attr = {
    name = "${var.name}-task-role"
    policy=  {
        "Version" : "2012-10-17",
        "Statement" : [
            {
                "Effect" : "Allow",
                "Action" : ["logs:CreateLogGroup", "ecs:*","ecr:*"],
                "Resource" : "*"
            }
        ]
    }
  }
}