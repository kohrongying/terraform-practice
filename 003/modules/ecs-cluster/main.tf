variable "name" {
  type = string
  default = "ecs-cluster"
}

resource "aws_ecs_cluster" "main" {
  name = var.name
}

output "cluster_id" {
  value = aws_ecs_cluster.main.id
}