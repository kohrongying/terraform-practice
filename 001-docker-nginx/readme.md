# Problem

Issue: Running Nginx in AWS.

Requirements:

1. Running Nginx in Docker in EC2.
2. Creating EC2 by Terraform.
3. We can access Nginx from the Internet.
4. Terraform state files should be saved in AWS S3. (nice to have)
5. Using the Terraform module to create EC2. (nice to have)

## My methodology

### Iteration 0

- [x] create ec2 instance and nginx from scratch (ssh into instance, install docker. pull nginx container. run docker image on port)
- [x] create another ec2 but use remote exec / user data

Note: require security group
- create secrutiy group for ssh access and inbound access on port 80

### Iteration 1
- [x] Use default vpc, existing SG, Create ec2 on terraform, save ip address into txt file
- [x] Use default vpc, existing SG, Create ec2 on terraform, use ami variable, save ip address into output var

### Iteration 2
- [x] save state file on s3
- [] add state locking on dynamo db

### Iteration 3
- [x] Create vpc, security group, ec2 with aws modules

## Learnings
- If you have a new backend, need to terraform init
- If you specify a count, you should use * in your output if you refer to all
- Put s3 bucket and dynamodb (for storing tfstate) in another folder to separate its concerns

## How to run
1. Run `terraform init` and `terraform apply` in backend first to create s3 bucket and dynamodb (change name)
2. Run `terraform init` and `terraform apply` in nginx