output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnets" {
  value = merge(zipmap(var.public_subnets[*].name, values(aws_subnet.public_subnets)[*].id), zipmap(var.private_subnets[*].name, values(aws_subnet.private_subnets)[*].id))
}

output "security_groups" {
  value = zipmap(concat(keys(aws_security_group.depth_zero), keys(aws_security_group.depth_one), keys(aws_security_group.depth_two), keys(aws_security_group.depth_three)), concat(values(aws_security_group.depth_zero), values(aws_security_group.depth_one), values(aws_security_group.depth_two), values(aws_security_group.depth_three))[*].id)
}
