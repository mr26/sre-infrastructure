resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

}

resource "aws_subnet" "priv_subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "priv_subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "priv_subnet3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_subnet" "pub_subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
  "kubernetes.io/role/elb" = "1"
}
}

resource "aws_subnet" "pub_subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  tags = {
  "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "pub_subnet3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1c"
  tags = {
  "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_main_route_table_association" "rtba1" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_eip" "nat_ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  subnet_id     = aws_subnet.pub_subnet1.id
  allocation_id = aws_eip.nat_ip.id
}

resource "aws_route_table" "priv_rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_route_table_association" "rtba2" {
  subnet_id      = aws_subnet.priv_subnet1.id
  route_table_id = aws_route_table.priv_rtb.id
}

resource "aws_route_table_association" "rtba3" {
  subnet_id      = aws_subnet.priv_subnet2.id
  route_table_id = aws_route_table.priv_rtb.id
}

resource "aws_route_table_association" "rtba4" {
  subnet_id      = aws_subnet.priv_subnet3.id
  route_table_id = aws_route_table.priv_rtb.id
}

resource "aws_security_group" "eks_sec_grp" {
  name        = "eks_sg"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.eks_sec_grp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.eks_sec_grp.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "api_cluster2_sec_grp" {
  name        = "api_cluster2_sg"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "api_cluster_2_rule1" {
  security_group_id = aws_security_group.api_cluster2_sec_grp.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
}