# terraform network infrastructure
network IaC

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.64.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_rta](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_rta](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.sg_child](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sg_parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | <pre>list(object({<br>      name = string<br>      cidr_block = string<br>      availability_zone = string<br>      tags = map(string)<br>  }))</pre> | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | <pre>list(object({<br>      name = string<br>      cidr_block = string<br>      map_public_ip_on_launch = bool<br>      availability_zone = string<br>      tags = map(string)<br>  }))</pre> | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | n/a | <pre>list(object({<br>      name = string<br>      description = string<br>      ingress = list(object({<br>           description = string<br>           from_port = number<br>           to_port   = number<br>           protocol  = string<br>           cidr_blocks = list(string)     <br>           ipv6_cidr_blocks = list(string) <br>           prefix_list_ids = list(string) <br>           security_groups = list(string) <br>           self = bool<br>       }))<br>       egress = list(object({<br>           description = string<br>           from_port = number<br>           to_port   = number<br>           protocol  = string<br>           cidr_blocks = list(string)     <br>           ipv6_cidr_blocks = list(string) <br>           prefix_list_ids = list(string) <br>           security_groups = list(string) <br>           self = bool<br>       }))<br>       tags = map(string)<br>  }))</pre> | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | n/a | <pre>object({<br>    cidr_block = string<br>    enable_dns_support = bool<br>    enable_dns_hostnames = bool<br>    tags = map(string)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | n/a |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | n/a |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
