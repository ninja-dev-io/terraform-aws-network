locals {
  parent_groups = {for group in var.security_groups: group.name => group if length(flatten([for rule in concat(group.ingress, group.egress): rule.security_groups])) == 0}
  child_groups = {for group in var.security_groups: group.name => group if lookup(local.parent_groups, group.name, null) == null}
  applied_groups = {for group in values(aws_security_group.sg_parent)[*] : group.name => group.id} 
}


resource "aws_security_group" "sg_parent" {
  for_each    = local.parent_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  ingress     = each.value.ingress
  egress      = each.value.egress
  tags = each.value.tags != null ? merge(each.value.tags, {Environment = "${var.env}"}) : {Name = "security-group-${var.env}-${index(var.security_groups[*].name, each.value.name) + 1}"}
}

resource "aws_security_group" "sg_child" {
  for_each    = local.child_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  ingress     = length(each.value.ingress) == 0 ? each.value.ingress : [for rule in each.value.ingress: length(rule.security_groups) > 0 ? merge(rule, {security_groups: [for group in rule.security_groups: lookup(local.applied_groups, group)]}) : rule] 
  egress      = length(each.value.egress) == 0 ? each.value.egress : [for rule in each.value.egress: length(rule.security_groups) > 0 ? merge(rule, {security_groups: [for group in rule.security_groups: lookup(local.applied_groups, group)]}) : rule] 
  tags = each.value.tags != null ? merge(each.value.tags, {Environment = "${var.env}"}) : {Name = "security-group-${var.env}-${index(var.security_groups[*].name, each.value.name) + 1}"}
  depends_on    = [aws_security_group.sg_parent]
}

