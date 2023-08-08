# OUTPU TO RETRIVE ALL PUBLIC INSTANCES IP
output "public_ec2_id" {
  value = aws_instance.pub-ec2[*].id
}

# OUTPUT TO RETRIVE ALL PRIVATE INSTANCES IP
output "private_ec2_id" {
  value = aws_instance.priv-ec2[*].id
}

# OUTPUT TO RETRIVE SECURITY GROUP ID TO BE USED IN LOAD BALANCER 
output "security_group_id" {
    value = aws_security_group.sg.id
}