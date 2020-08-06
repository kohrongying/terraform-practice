resource "aws_ecs_task_definition" "main" {
  family                = "${var.name}-task"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512

  // awsvpc required for FARGATE
  // an elastic network interface is assigned to each running task
  network_mode             = "awsvpc" 
  
  container_definitions = var.container_definitions
  
  // Fargate requires task definition to have execution role ARN to support log driver awslogs.
  execution_role_arn = var.execution_role_arn
}

resource "aws_ecs_service" "main" {
  name            = "${var.name}-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type = "FARGATE"
  
  load_balancer {
    container_name = var.name
    container_port = var.port
    target_group_arn = aws_lb_target_group.main.arn
  }

  // must provide when networkMode is awsvpc
  network_configuration {
    assign_public_ip = true
    security_groups = var.security_groups
    subnets = var.subnet_ids
  }

  depends_on = [aws_lb.main]
}

resource "aws_lb" "main" {
  name = "${var.name}-lb"
  load_balancer_type = "application"
  security_groups = var.security_groups
  subnets = var.subnet_ids
}

resource "aws_lb_target_group" "main" {
  name  = "${var.name}-target-group"
  port  = var.port
  protocol = "HTTP"

  vpc_id = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}