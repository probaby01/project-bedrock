output "pb_vpc_id" {
  value = aws_vpc.pb_vpc.id
}

output "pb_sg_id" {
  value = aws_security_group.pb_sg.id
}

output "pb_private_subnets_ids" {
  value = aws_subnet.pb_private_subnets[*].id
}