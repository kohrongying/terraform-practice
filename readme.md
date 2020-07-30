# Terraform Practice

## 001 - Running Nginx in AWS

Requirements:
1. Running Nginx in Docker in EC2.
2. Creating EC2 by Terraform.
3. We can access Nginx from the Internet.
4. Terraform state files should be saved in AWS S3. (nice to have)
5. Using the Terraform module to create EC2. (nice to have)

## 002 - Advanced 
Requirements:
1. Service-1 running in dedicated VPC.
2. Server-1 running in Private Subnet. (Cannot Access directly).
3. Server-1 should have High Availability(Load Balancer).
4. Server-1 EC2 has an Auto-Scaling Group.
5. It should have 2 Environments(Dev and Prod).
6. IaC is required.
7. Using Terragrunt instead of Terraform directly.

Note to self:
- When using data variable for ami from the net, check to use the correct version. Certain version may be imcompatible with whatever is in your user data
- When creating the ami from ec2, docker container will stop. When using launch config, user data should restart the container 