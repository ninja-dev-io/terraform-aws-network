variable "env" {
  type = string
}

variable "vpc" {
  type = object({
    cidr_block = string
    enable_dns_support = bool
    enable_dns_hostnames = bool
    tags = map(string)
  })
}

variable "public_subnets" {
  type = list(object({
      name = string
      cidr_block = string
      map_public_ip_on_launch = bool
      availability_zone = string
      tags = map(string)
  }))
}

variable "private_subnets" {
  type = list(object({
      name = string
      cidr_block = string
      availability_zone = string
      tags = map(string)
  }))
}

variable "security_groups" {
  type = list(object({
      name = string
      description = string
      ingress = list(object({
           description = string
           from_port = number
           to_port   = number
           protocol  = string
           cidr_blocks = list(string)     
           ipv6_cidr_blocks = list(string) 
           prefix_list_ids = list(string) 
           security_groups = list(string) 
           self = bool
       }))
       egress = list(object({
           description = string
           from_port = number
           to_port   = number
           protocol  = string
           cidr_blocks = list(string)     
           ipv6_cidr_blocks = list(string) 
           prefix_list_ids = list(string) 
           security_groups = list(string) 
           self = bool
       }))
       tags = map(string)
  }))
}




   