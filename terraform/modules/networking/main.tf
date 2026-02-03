resource "aws_vpc" "pb_vpc" {
  cidr_block = "var.cidr_block"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "pb_public_subnet" {
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.pb_vpc.id
  cidr_block              = "cidrsubnet(var.cidr_block, 8, count.index)"
  map_public_ip_on_launch = true

  tags = {
    Name                                                = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                            = "1"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

resource "aws_subnet" "pb_private_subnet" {
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.pb_vpc.id
  cidr_block              = "cidrsubnet(var.cidr_block, 8, count.index)"

  tags = {
    Name                                                = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                            = "1"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

resource "aws_internet_gateway" "pb_igw" {
  vpc_id = aws_vpc.pb_vpc.id

  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
}

resource "aws_eip" "pb_nat_eip" {
  vpc = aws_vpc.pb_vpc.id
  count = length(var.availability_zones)

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "pb_nat_gw" {
  allocation_id = aws_eip.pb_nat_eip[count.index].id
  subnet_id     = aws_subnet.pb_public_subnet[count.index].id
  count         = length(var.availability_zones)

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}

resource "aws_route_table" "pb_public_rt" {
  vpc_id = aws_vpc.pb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pb_igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.pb_public_subnet)
  subnet_id      = aws_subnet.pb_public_subnet[count.index].id
  route_table_id = aws_route_table.pb_public_rt.id
}

resource "aws_route_table" "pb_private_rt" {
  vpc_id = aws_vpc.pb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pb_nat_gw[count.index].id
  }
  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.pb_private_subnet)
  subnet_id      = aws_subnet.pb_private_subnet[count.index].id
  route_table_id = aws_route_table.pb_private_rt[count.index].id
}

resource "aws_security_group" "pb_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for project bedrock"
  vpc_id      = aws_vpc.pb_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-security-group"
  }
}