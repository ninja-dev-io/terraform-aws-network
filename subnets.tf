locals {
  availability_zones = {
    for az in setintersection(
      distinct([for subnet in var.private_subnets: subnet.availability_zone]),
      distinct([for subnet in var.public_subnets: subnet.availability_zone])
    ) :  az => az
  } 
  subnets_by_az = {
    for subnet in values(aws_subnet.public_subnets)[*] : subnet.availability_zone => subnet.id...
  }
}

resource "aws_subnet" "public_subnets" {
    for_each = {for subnet in var.public_subnets:  subnet.name => subnet}
    vpc_id = aws_vpc.vpc.id
    cidr_block = each.value.cidr_block
    map_public_ip_on_launch = true
    availability_zone = each.value.availability_zone
    tags = each.value.tags != null ? merge(each.value.tags, {Environment = "${var.env}"}) : {Name = "public-subnet-${var.env}-${index(values(var.public_subnets)[*]["name"], each.value.name) + 1}"}
}

resource "aws_subnet" "private_subnets" {
    for_each = {for subnet in var.private_subnets:  subnet.name => subnet}
    vpc_id = aws_vpc.vpc.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone
    tags = each.value.tags != null ? merge(each.value.tags, {Environment = "${var.env}"}) : {Name = "private-subnet-${var.env}-${index(values(var.private_subnets)[*]["name"], each.value.name) + 1}"}
}
