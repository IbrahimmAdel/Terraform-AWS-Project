# VARIABLE TO GET THE VPC ID TO BE USED IN SECURITY GROUP
variable "sg_vpc_id"{
  type = string
}

# variable used in nginx script to proxy to the private load balancer
variable "priv_lb_dns" {} 

# VARIABLE TO CREATE 1 INSTANCE IN EACH PUBLIC SUBNET
variable "ec2_public_subnet_id" {
  type = list
}


# VARIABLE TO CREATE 1 INSTANCE IN EACH PRIVATE SUBNET
variable "ec2_private_subnet_id" {
  type = list
}


