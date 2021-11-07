locals {
  nat_eip_by_az = zipmap(keys(local.availability_zones), values(aws_eip.nat_eip)[*].id)
  nat_by_az = zipmap(keys(local.availability_zones), values(aws_nat_gateway.nat)[*].id)
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {Name = "igw-${var.env}"}
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  for_each = local.availability_zones
  vpc        = true
  tags = { Name = "nat-eip-${var.env}-${index(keys(local.availability_zones), each.value) + 1}" }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  for_each = local.availability_zones
  allocation_id = lookup(local.nat_eip_by_az, each.value)
  subnet_id     = element(lookup(local.subnets_by_az, each.value), 0)
  depends_on    = [aws_internet_gateway.igw, aws_subnet.public_subnets]
  tags = { Name = "nat-${var.env}-${index(keys(local.availability_zones), each.value) + 1}" }
}

