provides multiple environments with a backbone infrastructure.

#### backbone
  * 2 public subnet
  * 2 private subnet
  * eip for bastion instance
  * eip for nat gateway
  * internet gateway and nat gateways to provide access for public & private subnets
  * route table modifications for igw and nat gateway
  * vpc peering connection for access to rds server
    * route table modifications to allow vpc peering
  * bastion instance for access to servers
  * application load balancer to public subnets
  * alb security group
    * opens 443 and 80 to 0.0.0.0
  * app security group
    * opens application ports to intra-vpc traffic
  * bastion security group
    * opens 22 to set IPs
