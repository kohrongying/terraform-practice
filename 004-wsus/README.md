# WSUS

This is a spike to test how to patch a windows EC2 instance in a private subnet.

## Set up Architecture

1. Have to use RD Gateway Quick Start Cloudformation
2. Use the vpc to launch the private windows instance in
3. Update the variables

```
// vpc.tf
locals {
   //TODO to change
  rdgw_vpc = "vpc-0887e78b609ba61ab"
  rdgw_vpc_cidr = "10.0.2.0/24"
  my_ip = ""
}
```
4. Run terraform apply
5. Add vpc peering id to rdgw vpc route tables
6. Add RDGW EC2 Instance security group as the rdp-tcp source security group id ingress rule for the private Windows instance


## Resources
- 2 VPCs
- VPC Peering
- 5 VPC Endpoints in Private Subnet of Private Windows Instance (to enable ssm patching)
- 3 Windows Instances
  - 1 WSUS 
  - 1 Private EC2
  - 1 RDGW (created by cloudformation template)


# Configure WSUS
1. Remote Desktop into WSUS instance
2. [Install WSUS Server Role](https://docs.microsoft.com/en-us/windows-server/administration/windows-server-update-services/deploy/1-install-the-wsus-server-role)
3. [Configure WSUS](https://docs.microsoft.com/en-us/windows-server/administration/windows-server-update-services/deploy/2-configure-wsus)

# Configure Private Windows EC2
1. Remote Desktop into Private Windows ([instructions](https://www.notion.so/Connecting-to-a-Windows-EC2-in-private-subnet-98db96276d4444e19e19628096744555))
2. Update the Windows Agent to the IP address of WSUS Server
