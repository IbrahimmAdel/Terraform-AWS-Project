# CREATE AMI TO BE USED IN EC2
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

# CREATE A SECURITY GROUP
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

# LAUNCHE PUBLIC EC2 INSTANCES
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

# LAUNCHE PRIVATE EC2 INSTANCES
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

