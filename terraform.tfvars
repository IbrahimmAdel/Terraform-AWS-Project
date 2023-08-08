# providers values 
profile  = "test"
region   = "us-east-1"

# vpc module values
vpc_cidr = "10.0.0.0/16"

# subnet  module values
pub_subnet = [
    { subnets_cidr      = "10.0.0.0/24"
      availability_zone = "us-east-1a" },
    { subnets_cidr      = "10.0.2.0/24"
      availability_zone = "us-east-1b"}
]

priv_subnet = [
    { subnets_cidr      = "10.0.1.0/24"
      availability_zone = "us-east-1a"},
    { subnets_cidr      = "10.0.3.0/24"
     availability_zone  = "us-east-1b" }
]

# loadbalancer  module values
lb_internal = [false,true]



