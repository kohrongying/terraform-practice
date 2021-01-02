output "vpc_ingress" {
  description = "The ID of the VPC"
  value       = {
    vpc_id = module.vpc_ingress.vpc_id
    subnets = module.vpc_ingress.public_subnets
    cidr = module.vpc_ingress.vpc_cidr_block
    route_table_ids = module.vpc_ingress.public_route_table_ids
  }
}