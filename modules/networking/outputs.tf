output "public_subnet1" {
  value = aws_subnet.pub_subnet1.id
}

output "public_subnet2" {
  value = aws_subnet.pub_subnet1.id
}

output "main_vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet1" {
  value = aws_subnet.priv_subnet1.id
}

output "private_subnet2" {
  value = aws_subnet.priv_subnet2.id
}

output "private_subnet3" {
  value = aws_subnet.priv_subnet3.id
}

output "eks_sg" {
  value = aws_security_group.eks_sec_grp.id
}

output "api_cluster2_sec_grp" {
  value = aws_security_group.api_cluster2_sec_grp.id
}