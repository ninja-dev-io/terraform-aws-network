output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnets" {
  value = local.subnets
}

output "security_groups" {
  value = local.security_groups
}
