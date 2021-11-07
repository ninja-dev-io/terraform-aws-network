output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = zipmap(var.public_subnets[*].name, values(aws_subnet.public_subnets)[*].id)
}

output "private_subnets" {
  value = zipmap(var.private_subnets[*].name, values(aws_subnet.private_subnets)[*].id)
}

output "security_groups" {
  value = zipmap(concat(keys(local.parent_groups), keys(local.child_groups)), concat(values(aws_security_group.sg_parent), values(aws_security_group.sg_child))[*].id)
}