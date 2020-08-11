locals {
  flask_port = "5000"
  service1_name = "flask"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
variable "cluster_id" {}

variable "execution_role_arn" {}
variable "security_groups" {
  type = list(string)
  default = []
}
variable "sg_ingress_cidr_blocks" {
  type = list(string)
  default = []
}

module "flask" {
  source = "../../..//services-shared/modules/ecs-service"
  port = local.flask_port
  name = local.service1_name
  subnet_ids = var.subnet_ids
  security_groups = concat([aws_security_group.allow_port_5000.id], var.security_groups)
  vpc_id = var.vpc_id
  container_definitions = <<EOF
  [{
    "name": "${local.service1_name}",
    "image": "rongdock/flask-api:latest",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [{
        "containerPort": ${local.flask_port}
      }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group" : "${local.service1_name}",
          "awslogs-region": "ap-southeast-1",
          "awslogs-stream-prefix": "ecs"
      }
    }
  }]
  EOF
  ecs_cluster_id = var.cluster_id
  execution_role_arn = var.execution_role_arn
}

resource "aws_security_group" "allow_port_5000" {
  name = "allow web on port 5000"
  vpc_id = var.vpc_id
  ingress {
    from_port = local.flask_port
    to_port = local.flask_port
    cidr_blocks = var.sg_ingress_cidr_blocks
    protocol = "tcp"
  }
  ingress {
    from_port = 80
    to_port = 80
    cidr_blocks = var.sg_ingress_cidr_blocks
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}