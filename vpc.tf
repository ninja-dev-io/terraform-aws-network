resource "aws_vpc" "vpc" {
    cidr_block = var.vpc.cidr_block
    enable_dns_support = var.vpc.enable_dns_support
    enable_dns_hostnames = var.vpc.enable_dns_hostnames
    tags = var.vpc.tags != null ? merge(var.vpc.tags, {Environment = "${var.env}"}) : {Name = "vpc-${var.env}"}
}


