locals {
  private_rt_by_az = zipmap(keys(local.availability_zones), values(aws_route_table.private_rt)[*].id)
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {Name = "public-rt-${var.env}"}
}

resource "aws_route_table" "private_rt" {
  for_each = local.availability_zones
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "private-rt-${var.env}-${index(keys(local.availability_zones), each.value) + 1}" }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_nat_gateway" {
  for_each = local.availability_zones
  route_table_id         =  lookup(local.private_rt_by_az, each.value)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         =  lookup(local.nat_by_az, each.value)
}

resource "aws_route_table_association" "public_rta" {
  for_each = {for index, subnet in var.public_subnets: index => subnet.name} 
  subnet_id      = element(values(aws_subnet.public_subnets)[*].id, tonumber(each.key))
  route_table_id = aws_route_table.public_rt.id
  depends_on    = [aws_subnet.public_subnets]
}

resource "aws_route_table_association" "private_rta" {
  for_each = {for index, subnet in var.private_subnets: index => subnet.availability_zone} 
  subnet_id      = element(values(aws_subnet.private_subnets)[*].id, tonumber(each.key))
  route_table_id = lookup(local.private_rt_by_az, each.value)
  depends_on     = [aws_subnet.private_subnets]
}
