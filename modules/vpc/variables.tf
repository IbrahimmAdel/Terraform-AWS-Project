# VPC VARIALES
variable "vpc_cidr" { 
    description = "VPC CIDR"
    type = string 
    }
# NAT VARIABLES
variable "nat_subnet_id"{
    description = "The subnet ID of the public subnet in which to place the gateway"
    type = string
}