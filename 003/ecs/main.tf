locals {
  flask_port = "5050"
  node_port = "8080"
  service1_name = "flask"
  service2_name = "node"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

module "service1" {
  source = "../../003-modules/ecs-service"
  port = local.flask_port
  name = local.service1_name
  subnet_ids = var.subnet_ids
  security_groups = [aws_security_group.allow_port_5000.id, aws_security_group.allow_port_80.id]
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
  ecs_cluster_id = aws_ecs_cluster.main.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

module "service2" {
  source = "../../003-modules/ecs-service"
  port = local.node_port
  name = local.service2_name
  subnet_ids = var.subnet_ids
  security_groups = [aws_security_group.allow_port_8080.id, aws_security_group.allow_port_80.id]
  vpc_id = var.vpc_id
  container_definitions = <<EOF
  [{
    "name": "${local.service2_name}",
    "image": "rongdock/node-web-app:latest",
    "environment": [
      {
        "name": "BASE_URL",
        "value": "${module.service1.lb_dns}"
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
  ecs_cluster_id = aws_ecs_cluster.main.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

resource "aws_security_group" "allow_port_5000" {
  name = "allow web on port 5000"
  vpc_id = var.vpc_id
  ingress {
    from_port = 5000
    to_port = 5000
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

resource "aws_security_group" "allow_port_8080" {
  name = "allow web on port 8080"
  vpc_id = var.vpc_id
  ingress {
    from_port = 8080
    to_port = 8080
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

resource "aws_security_group" "allow_port_80" {
  name = "allow web on port 80"
  vpc_id = var.vpc_id
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