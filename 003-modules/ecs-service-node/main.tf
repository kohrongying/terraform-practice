locals {
  node_port = "8080"
  service2_name = "node"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "cluster_id" {}
variable "execution_role_arn" {}
variable "base_url_env_variable" {}
variable "security_groups" {
  type = list(string)
  default = []
}
variable "ingress_cidr_blocks" {}

module "service2" {
  source = "../ecs-service"
  port = local.node_port
  name = local.service2_name
  subnet_ids = var.subnet_ids
  security_groups = concat([aws_security_group.allow_port_8080.id], var.security_groups)
  vpc_id = var.vpc_id
  container_definitions = <<EOF
  [{
    "name": "${local.service2_name}",
    "image": "rongdock/node-web-app:latest",
    "environment": [
      {
        "name": "BASE_URL",
        "value": "${var.base_url_env_variable}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group" : "${local.service2_name}",
          "awslogs-region": "ap-southeast-1",
          "awslogs-stream-prefix": "ecs"
      }
    },
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [{
        "containerPort": ${local.node_port}
      }]
  }]
  EOF
  ecs_cluster_id = var.cluster_id
  execution_role_arn = var.execution_role_arn
}

resource "aws_security_group" "allow_port_8080" {
  name = "allow web on port 8080"
  vpc_id = var.vpc_id
  ingress {
    from_port = local.node_port
    to_port = local.node_port
    cidr_blocks = ["10.0.0.128/27", "10.0.0.160/27"]
    protocol = "tcp"
  }
  ingress {
    from_port = 80
    to_port = 80
    cidr_blocks = ["10.0.0.128/27", "10.0.0.160/27"]
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
