**Release includes the below aws resources**
### networking
* route53 record <sub_domain>-a-s.db.alphastack
* vpc
* subnet
* application load balancer
  * listeners on 80 and 443
  * security group for alb

### resources
* instance security group
  * ingress 8888
* instance with clairity accessible on port 8888
* security group rule allowing 3306 access to the rds instance


```
module "clairity" {
  source  = "app.terraform.io/AlphaStack/clairity/aws"
  version = "0.1.3-alpha"

  # insert required variables here
}
```
