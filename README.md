# Terraform Infrastructure Deployment Project

Welcome to the Terraform Infrastructure Deployment Project. This project demonstrates the implementation of a multi-tier infrastructure on AWS using Terraform.

## Project Overview

This project showcases the deployment of a multi-tier infrastructure on AWS using Terraform. The project includes the following features:

1. Usage of custom modules to create a robust and scalable architecture.
2. Multiple workspaces with the primary focus on the 'dev' workspace.
3. Remote state management using an S3 bucket.
4. Installation of Apache or a proxy server on instances with IP details logged to a file.
5. Utilization of a data source to fetch the EC2 image ID.
6. Configuration of a public-facing Load Balancer and a private Load Balancer.
7. Demonstrates sending traffic to private instances through the public Load Balancer.

## Architecture Diagram

![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/project.png)

## Project Structure

- `main.tf`: Main Terraform configuration file.
- `variables.tf`: Input variables used in the Terraform configuration.
- `terraform.tfvars`: values of the variables in **variables.tf**.
- `modules/`: Custom modules used for different components.
- `all-ips.txt`: Output file with IP details.

## Getting Started

1. Clone this repository:
```
git clone https://github.com/IbrahimmAdel/Terraform-Project.git
```
2. Navigate to the project directory:
```
cd terraform-project
```
3. Initialize Terraform:
```
terraform init
```
4. Review and modify **variables** as needed.
   
5. Apply the configuration:
```
terraform apply
```
---
## modules details 

### [vpc module](https://github.com/IbrahimmAdel/Terraform-Project/tree/master/modules/vpc)
this module contains:

- vpc
```
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "sprints-VPC"
  }
}
```
- IGW
```
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "sprints-IGW"
  }
}
```
- Elastic IP
```
resource "aws_eip" "eip" {
  domain   = "vpc"
}
```
- NAT
```
esource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.nat_subnet_id
  tags = {
    Name = "sprints-NAT"
  }
  # To ensure proper ordering, i will add an explicit dependency on the Internet Gateway.
  depends_on = [aws_internet_gateway.igw]
}
```

## [subnet module](https://github.com/IbrahimmAdel/Terraform-Project/tree/master/modules/subnet)
this module contains:

- number of public subnets (based on number of variables)
```
resource "aws_subnet" "public_subnets" {
  count             = length(var.pub_subnets)
  vpc_id            = var.vpc_id
  cidr_block        = var.pub_subnets[count.index].subnets_cidr
  availability_zone = var.pub_subnets[count.index].availability_zone
  tags = {
    Name = "sprints_public_subnet_${count.index}"
  }
}
```
- route table for public subnets
```
resource "aws_route_table" "public-rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}
```
- route table association for public subnets
```
resource "aws_route_table_association" "public-rta" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public-rt.id
}
```
- number of private subnets (based on number of variables)
```
resource "aws_subnet" "private_subnets" {
  count             = length(var.priv_subnets)
  vpc_id            = var.vpc_id
  cidr_block        = var.priv_subnets[count.index].subnets_cidr
  availability_zone = var.priv_subnets[count.index].availability_zone
  tags = {
    Name = "sprints_private_subnet_${count.index}"
  }
}
```
- route table for private subnets
```
resource "aws_route_table" "private-rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_id
  }
}
```
- route table association for private subnets
```
resource "aws_route_table_association" "private-rta" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id   
  route_table_id = aws_route_table.private-rt.id
}
```

## [EC2 module](https://github.com/IbrahimmAdel/Terraform-Project/tree/master/modules/ec2)
this module contains:

- ubuntu AMI
```
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["099720109477"]
}
```
- EC2 security group
```
resource "aws_security_group" "sg" {
  vpc_id = var.sg_vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sprints_sg"
  }
}
```
- number of EC2s in public subnets (based on number of variables)
```
resource "aws_instance" "pub-ec2" {
  count                       = length(var.ec2_public_subnet_id) 
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = var.ec2_public_subnet_id[count.index]    
  security_groups             = [aws_security_group.sg.id]
  associate_public_ip_address = true
  tags = {
      Name = "sprints_public_ec2_${count.index}"
    } 

    user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo cat > /etc/nginx/sites-enabled/default << EOL
server {
    listen 80 default_server;
    location / {
      proxy_pass http://${var.priv_lb_dns};
    }
}
  
EOL
sudo systemctl restart nginx
EOF

  provisioner "local-exec" {
    when        = create
    on_failure  = continue
    command = "echo public-ip-${count.index} : ${self.private_ip} >> all-ips.txt"
 }
}
```
- number of EC2s in private subnets (based on number of variables)
```
resource "aws_instance" "priv-ec2" {
  count                       = length(var.ec2_private_subnet_id) 
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = var.ec2_private_subnet_id[count.index]    
  security_groups             = [aws_security_group.sg.id]
  associate_public_ip_address = false
  
  tags = {
    Name = "sprints_private_ec2_${count.index}"  
  }
    user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
systemctl restart apache2
EOF

  provisioner "local-exec" {
    when        = create
    on_failure  = continue
    command = "echo private-ip-${count.index} : ${self.private_ip} >> all-ips.txt"
 }
} 
```

## [LoadBalancer module](https://github.com/IbrahimmAdel/Terraform-Project/tree/master/modules/loadbalancer)
this module contains:

- 2 target groups
```
resource "aws_lb_target_group" "tg" {
    count    = 2
    port     = 80
    protocol = "HTTP"   
    vpc_id   = var.lb_vpc_id
}
```
- Attachment to attach first target group with public subnets
```
resource "aws_lb_target_group_attachment" "public-target-group-attachment" {
    count            = length(var.pub_target_id)
    target_group_arn = aws_lb_target_group.tg[0].arn
    target_id        = var.pub_target_id[count.index]
    port             = 80
}
```
- Attachment to attach second target group with private subnets

```
resource "aws_lb_target_group_attachment" "private-target-group-attachment" {
    count            = length(var.priv_target_id)
    target_group_arn = aws_lb_target_group.tg[1].arn
    target_id        = var.priv_target_id[count.index]
    port             = 80
}
```
- 2 loadbalancers (for the font-end tier and back-end tier)
```
resource "aws_lb" "load-balancer" {
    count                      = 2
    name                       = "sprints-load-balancer-${count.index}"
    internal                   = var.lb_internal[count.index]
    load_balancer_type         = "application"
    subnets                    = var.lb_subnets[count.index]     
    security_groups            = [var.lb_sg_id]
    # enable_deletion_protection = true
}
```

- 2 loadbalancer listeners
```
resource "aws_lb_listener" "lb-listner" {
    count             = 2
    load_balancer_arn = aws_lb.load-balancer[count.index].id
    port              = "80"
    protocol          = "HTTP"
    default_action {
        type  = "forward"
        target_group_arn = aws_lb_target_group.tg[count.index].id
  }
}
```

---
## Screenshots

#####  *create a new workplace `dev` to work on it*
- ![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/workspace.png)
----
#### *proxy configuration*
- ![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/proxy%20configuration.png)
-----
#### *The apache page of the private EC2 through public Loadbalancer DNS*
- ![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/load-balancer.png)
-----
#### *The s3 bucket that contain the state file*
- ![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/s3.png)














