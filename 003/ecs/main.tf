provider "aws" {
  profile = "default"
  region = "ap-southeast-1"
}

variable "nginx_service_name" {
  default = "nginx"
  type = string
}

variable "web_service_name" {
  default = "web"
  type = string
}

variable "port" {
  default = "80"
  type = string
}


module "service1" {
  source = "../../003-modules/ecs-service"
  port = var.port
  name = var.nginx_service_name
  subnet_ids = data.aws_subnet_ids.default.ids
  security_groups = ["sg-09049d812ef437d56"]
  vpc_id = "vpc-4d2fc92b"
  container_definitions = <<EOF
  [{
    "name": "${var.nginx_service_name}",
    "image": "nginx:latest",
    "cpu": 10,
    "memory": 10,
    "essential": true,
    "portMappings": [{
        "containerPort": ${var.port}
      }],
    "logConfiguration": { 
      "logDriver": "awslogs",
      "options": { 
          "awslogs-group" : "${var.nginx_service_name}",
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
  port = var.port
  name = var.web_service_name
  subnet_ids = data.aws_subnet_ids.default.ids
  security_groups = ["sg-09049d812ef437d56"]
  vpc_id = "vpc-4d2fc92b"
  container_definitions = <<EOF
  [{
    "command": [
            "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
         ],
    "entryPoint": [
      "sh",
      "-c"
    ],
    "name": "${var.web_service_name}",
    "image": "httpd:2.4",
    "logConfiguration": { 
      "logDriver": "awslogs",
      "options": { 
          "awslogs-group" : "${var.web_service_name}",
          "awslogs-region": "ap-southeast-1",
          "awslogs-stream-prefix": "ecs"
      }
    },
    "cpu": 10,
    "memory": 10,
    "essential": true,
    "portMappings": [{
        "containerPort": ${var.port}
      }]
  }]
  EOF
  ecs_cluster_id = aws_ecs_cluster.main.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

data "aws_subnet_ids" "default" {
  vpc_id = "vpc-4d2fc92b"
}