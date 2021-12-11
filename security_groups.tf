resource "aws_security_group" "depth_zero" {
  for_each    = { for group in var.security_groups : group.name => group if group.depth == 0 }
  name        = "${each.value.name}-${var.env}"
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  ingress     = each.value.ingress
  egress      = each.value.egress
  tags        = each.value.tags != null ? merge(each.value.tags, { Environment = "${var.env}" }) : { Name = "security-group-${var.env}-${index(var.security_groups[*].name, each.value.name) + 1}" }
}

resource "aws_security_group" "depth_one" {
  for_each    = { for group in var.security_groups : group.name => group if group.depth == 1 }
  name        = "${each.value.name}-${var.env}"
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  ingress     = length(each.value.ingress) == 0 ? each.value.ingress : [for rule in each.value.ingress : length(rule.security_groups) > 0 ? merge(rule, { security_groups : [for group in rule.security_groups : lookup(aws_security_group.depth_zero, group).id] }) : rule]
  egress      = length(each.value.egress) == 0 ? each.value.egress : [for rule in each.value.egress : length(rule.security_groups) > 0 ? merge(rule, { security_groups : [for group in rule.security_groups : lookup(aws_security_group.depth_zero, group).id] }) : rule]
  tags        = each.value.tags != null ? merge(each.value.tags, { Environment = "${var.env}" }) : { Name = "security-group-${var.env}-${index(var.security_groups[*].name, each.value.name) + 1}" }
  depends_on  = [aws_security_group.depth_zero]
}

resource "aws_security_group" "depth_two" {
  for_each    = { for group in var.security_groups : group.name => group if group.depth == 2 }
  name        = "${each.value.name}-${var.env}"
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  ingress     = length(each.value.ingress) == 0 ? each.value.ingress : [for rule in each.value.ingress : length(rule.security_groups) > 0 ? merge(rule, { security_groups : [for group in rule.security_groups : lookup(merge(aws_security_group.depth_zero, aws_security_group.depth_one), group).id] }) : rule]
  egress      = length(each.value.egress) == 0 ? each.value.egress : [for rule in each.value.egress : length(rule.security_groups) > 0 ? merge(rule, { security_groups : [for group in rule.security_groups : lookup(merge(aws_security_group.depth_zero, aws_security_group.depth_one), group).id] }) : rule]
  tags        = each.value.tags != null ? merge(each.value.tags, { Environment = "${var.env}" }) : { Name = "security-group-${var.env}-${index(var.security_groups[*].name, each.value.name) + 1}" }
  depends_on  = [aws_security_group.depth_zero, aws_security_group.depth_one]
}

resource "aws_security_group" "depth_three" {
  for_each    = { for group in var.security_groups : group.name => group if group.depth == 3 }
  name        = "${each.value.name}-${var.env}"
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  ingress     = length(each.value.ingress) == 0 ? each.value.ingress : [for rule in each.value.ingress : length(rule.security_groups) > 0 ? merge(rule, { security_groups : [for group in rule.security_groups : lookup(merge(aws_security_group.depth_zero, aws_security_group.depth_one, aws_security_group.depth_two), group).id] }) : rule]
  egress      = length(each.value.egress) == 0 ? each.value.egress : [for rule in each.value.egress : length(rule.security_groups) > 0 ? merge(rule, { security_groups : [for group in rule.security_groups : lookup(merge(aws_security_group.depth_zero, aws_security_group.depth_one, aws_security_group.depth_two), group).id] }) : rule]
  tags        = each.value.tags != null ? merge(each.value.tags, { Environment = "${var.env}" }) : { Name = "security-group-${var.env}-${index(var.security_groups[*].name, each.value.name) + 1}" }
  depends_on  = [aws_security_group.depth_zero, aws_security_group.depth_one, aws_security_group.depth_two]
}
