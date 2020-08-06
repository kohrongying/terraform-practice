variable "port" {
  type = string
  default = "80"
}

variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "container_definitions" {}

variable "ecs_cluster_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
  default = ""
}