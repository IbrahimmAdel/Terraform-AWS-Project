# VARIABLES NEEDED IN TARGET GROUPS
variable "lb_vpc_id"{
    type = string
}
# VARIABLES NEEDED IN PUBLIC TARGET GROUP ATTACHMENT
variable "pub_target_id"{
    type = list(string)
}

# VARIABLES NEEDED IN PRIVATE TARGET GROUP ATTACHMENT
variable "priv_target_id"{
    type = list(string)
}

# VARIABLES NEEDED IN LOAD BALANCER
variable "lb_internal"{
    type = list(bool)
}

# list of [list of public subnets , list of private subnets]
variable "lb_subnets"{
    type = list(list(string))
}

variable "lb_sg_id"{}
