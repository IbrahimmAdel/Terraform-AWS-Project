# OUTPUT TO RETRIVE THE PUBLIC LOAD BALANCER DNS
output "public_load_balancer_dns" {
  value = aws_lb.load-balancer[0].dns_name
} 

# OUTPUT TO RETRIVE THE PRIVATE LOAD BALANCER DNS
output "private_load_balancer_dns" {
    value = aws_lb.load-balancer[1].dns_name
}