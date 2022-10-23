# Simple WebApp in AWS

- Create Virtual private network `VPC`
- Deploy simple application in `s3` bucket.
- Inject the code into `EC2s` that are managed by `ASG` 
- Keypair can be auto-generated and attached to `EC2`
- `EC2` proxied by external `ELB`.
- `IAM` service account that allows `EC2` a read access to `s3` bucket created above.
- Autoscaling group is dynamically scaling up and down ec2 capacity based on CPU metrics.
- `Route53` record can be added and aliased to ELB DNS record.

### How to run

As simple as 2 commands to run:

- Initialize terraform which will set up necessary providers that are resposible for making calls and create resources. 

```
terraform init
```

- Apply terraform
```
terraform apply
```

### SSH to EC2s

In case you want to `SSH` to EC2 for troubleshooting, you may need to add the following resource to `main.rf` in the root directory.

```
resource "local_file" "ssh_key" {
  filename = "file.pem"
  # change permission to 400, run `chmod 400 file.pem`, as it will not work
  content = module.webservers.keypair_private_key
}
```

### Modules:
- VPC: responsible for defining virtual network within AWS and its associated subnets.
- S3: defines a new bucket and uploads all contents inside `files` folder that's in the root.
- Service: deploy web service to autoscaling group that manages fleet of EC2 proxied by a load balancer to serve external http traffic.

#### VPC Module
| Name | Description| type| required | default
|------|------------|-------|------|----|
| name  |  vpc name     |  string      | No     | vpc |
| cidr | vpc cidr | string | yes | - |
| private_subnets | list of private subnets | list(string) | yes | - |
| public_subnets | list of public subnets | list(string) | yes | - |
| azs | list of availability zones. if not set, it will internally grab the list and cap it with the max length of public/private subnets | list(string) | no | list of azs fetched from aws | 
|nat_gateway | whether to deploy nat gateway | object({enabled: "true|false", single_az: "true|false" }) | `enabled: true` and `single_az: true` | - |

#### S3 Module
| Name | Description| type| required | default 
|------|------------|-------|------|----|
| name | name of s3 bucket | string | yes | - |
| dir | from where you need to upload files | string | no | `files` |

#### Service Module
| Name | Description| type| required | default |
|------|------------|-------|------|----|
| server_port | port number through which service is exposed in EC2 | number | no | 80 |
| elb_port | port number of ELB | number | no | 80 |
| ami_id | ami_id to use | string | no | ami-09d3b3274b6c5d4aa |
| instance_type | instance type to use | string | no | t3.micro |
| min_size | min number of instances in ASG | number | no | 1 |
| max_size | max number of instances in ASG | number | no | 2 |
| desired_capacity | desired capacity of instances in ASG | number | no | 1 |
| route53_hosted_zone_id | Zone id of route53 to create DNS record, aliasing record to ELB DNS | string | no | - |
| route53_record_name | record name to add withing hosted zone, aliasing record to ELB DNS | string | no | - |
| private_subnet_ids | private subnet ids to place EC2s on | list(string) | yes | - |
| public_subnet_ids | public subnet ids where LB should be created | list(string) | yes | - |
| vpc_id | which vpc to use to create service resources | string | yes | - |
| vpc_cidr | CIDR of VPC, used to open SSH access to EC2 within VPC CIDR only | string | yes | - |
| bucket | s3 bucket where to grab service code and inject into EC2 | string | yes | - |
| keypair | key pair name to create and attach to EC2 | string | no | - |

Note: this module depends on `s3` module as it needs s3 bucket to exist to be able to pull code from it.

### Assumptions:
- Since there was no specification whether to write complete vpc setup, I used vpc module to help creating the following resources:
    - VPC
    - Public subnets with their associated route tables
    - Private subnets with their associated route tables
    - Internet Gateway (attached to public subnets)
    - NAT gateways (attached to private subnets) - we can have single nat gateway which is not HA or have multiple NATs deployed to different AZs.
- SSH private key was not created manually, it is part of terraform, it is an optional to pass, it shouldn't be used to create pem files within CI/CD pipeline
- Remote access is open within defined VPC CIDR (local traffic). ssh from any bastion node that's in the public subnet

### Enhacements: 
- Switch to use ALB instead of ELB 
- Add TLS certificate in `Certificate Manager` and attach to `ELB` to enable `HTTPs`, enforce redirect from `http` to `https`
- State is managed locally however it should be managed in central store. I added an example in `providers.tf`
- Separate out `keypair` into its own module.
- Separate out `IAM` resources into its own module.
- Some refactoring and naming conventions revision.
- Add terraform linting in CI/CD (Github actions may be easy and quick).
- Wait to make sure we have at least one healthy EC2 before outputing LB DNS.
- Port 22 is open within VPC only, add ability to open port 22 for specific port (if provided).
- Away to trigger update to `nginx` in case s3 bucket file(s) change.