output "ssm_instance_profile" {
  value = aws_iam_instance_profile.ssm_profile.name
}

output "task_execution_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}