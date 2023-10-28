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
cd Terraform-AWS-Project
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
## modules

### [vpc module](https://github.com/IbrahimmAdel/Terraform-Project/tree/master/modules/vpc)
module resources :

- vpc
- IGW
- Elastic IP
- NAT


## [subnet module](https://github.com/IbrahimmAdel/Terraform-Project/tree/master/modules/subnet)
module resources :

- number of public subnets (based on number of variables)
- route table association for public subnets
- number of private subnets (based on number of variables)
- route table for private subnets
- route table association for private subnets

## [EC2 module](https://github.com/IbrahimmAdel/Terraform-Project/tree/master/modules/ec2)
module resources :

- ubuntu AMI
- EC2 security group
- number of EC2s in public subnets (based on number of variables)
- number of EC2s in private subnets (based on number of variables)

## [LoadBalancer module](https://github.com/IbrahimmAdel/Terraform-Project/tree/master/modules/loadbalancer)
module resources :

- 2 target groups
- Attachment to attach first target group with public subnets
- Attachment to attach second target group with private subnets
- 2 loadbalancers (for the font-end tier and back-end tier)
- 2 loadbalancer listeners

---
## Screenshots

#####  *create a new workplace `dev` to work on it*
![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/workspace.png)
----

#### *proxy configuration*
![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/proxy%20configuration.png)
-----

#### *apache page of the private EC2 through public Loadbalancer DNS*
![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/load-balancer.png)
-----

#### *s3 bucket that contain the state file*
![](https://github.com/IbrahimmAdel/Terraform-Project/blob/master/screenshots/s3.png)














