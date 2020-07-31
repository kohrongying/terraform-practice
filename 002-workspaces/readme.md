## Intro

This set up uses modules from the previous folder (vpc, instance, elb etc).

This set up is also to demonstrate how 

## Set up

```shell
// set up s3 and dynamo to store state
cd backend
terraform apply

// set up vpc
cd ../vpc
terragrunt workspace new dev // create new workspace
terragrunt apply

terragrunt workspace new prod // create new workspace
terragrunt apply

// set up web and high avail
cd ../services/web-server
terragrunt workspace new dev // create new workspace
terragrunt apply

terragrunt workspace new prod // create new workspace
terragrunt apply
```

## Outcome
- 2 vpcs, 2 elb, 2 asg (Names: `prac-002 - dev` and `prac-002 - prod`)