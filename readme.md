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

Solutions to multiple env:
1. Workspaces
```
|- vpc
    |- main.tf
|- web
    |- main.tf
```

2. Isolated env files
```
|- vpc
    |- dev.tf
    |- prod.tf
    |- shared.tf
|- web
    |- dev.tf
    |- prod.tf
    |- shared.tf
```

3. Isolated by folder
```
|- dev
    |- vpc
        |- main.tf
    |- web
        |- main.tf
|- prod
    |- vpc
        |- main.tf
    |- web
        |- main.tf
```


Note to self:
- When using data variable for ami from the net, check to use the correct version. Certain version may be imcompatible with whatever is in your user data
- When creating the ami from ec2, docker container will stop. When using launch config, user data should restart the container 
- specifying `remote_state` in root `terragrunt.hcl` file will autogenerate `backend.tf` in subfolders. If you have the `include` block in the `terragrunt.hcl` file in the subfolder
- Each folder is a separate terraform state. If you want to split up your resources, can. If you want to share the output of one terraform state with another, you have to either use `data` or `terraform_remote_state` but this won't work for outputs from modules.
- Using workspaces to denote environments
  * Can use `${terraform.workspace}` as the part of the name for variables
  * State files will all be stored in the same bucket, but under the env folder (separated by workspace name, as shown below) 
  * Cons: have to use same authentication and access controls
  * Cons: Not obvious what workspace you are in, may accidentally destroy resources in prod workspace thinking it was dev
- Using isolated files
  * Pros: it is faster to generate (don't have to change workspaces and apply, can just apply once)
  * Cons: Code is not DRY (provider, variables are declared once) - ok but the code is duplicated lol
  * Cons: Have to rename variables
  * Cons: Running terraform apply in the same folder may lead to accidental changes in prod

