# OUTPU TO RETRIVE ALL PUBLIC SUBNETS ID
output "public_subnets_id" {
    value = aws_subnet.public_subnets[*].id
}

# OUTPU TO RETRIVE ALL PUBLIC SUBNETS ID
output "private_subnets_id" {
    value = aws_subnet.private_subnets[*].id
}