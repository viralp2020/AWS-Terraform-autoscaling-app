Terraform Infrastructure as Code for AWS
This repository contains Terraform scripts to provision infrastructure on AWS including VPC, subnets, security groups, load balancer, autoscaling group, and more.

Table of Contents
Overview
Prerequisites
Setup
Terraform Configuration
Script
Usage
Cleanup
Overview
This Terraform configuration sets up a scalable web application infrastructure on AWS. It includes:

VPC and Subnets: Creates a VPC with multiple public subnets across different availability zones.
Internet Gateway and Route Table: Attaches an internet gateway to the VPC for internet access and sets up public route tables.
Security Groups: Defines security groups for EC2 instances (Web-server-SG and Sg-Public-ALB) and an application load balancer (Demo-LB).
Load Balancer: Configures an application load balancer (Demo-LB) with HTTP listener and target group.
Autoscaling Group: Sets up an autoscaling group (Demo-ASG) using a launch template (first-LT) to automatically scale EC2 instances based on CPU utilization.
Autoscaling Policy: Defines a target tracking autoscaling policy to maintain a target CPU utilization level.
Prerequisites
Before you begin, ensure you have:

AWS account with appropriate permissions to create resources.
AWS CLI installed and configured with access key and secret key.

Setup
1. Clone Repository:
https://github.com/viralp2020/AWS-Terraform-autoscaling-app.git
cd AWS-Terraform-autoscaling-app

2.Install Terraform:
Ensure Terraform is installed on your system. You can download it from Terraform Downloads.

3.AWS Configuration:
Configure your AWS credentials using AWS CLI:
run aws configure in CLI

Terraform Configuration
main.tf: Defines all AWS resources such as VPC, subnets, security groups, load balancer, autoscaling group, etc.
config.tf: Specifies Terraform configuration settings like required version and provider details.
script.sh: Contains user data script executed by EC2 instances.

Script
script.sh: User data script executed by EC2 instances to initialize and configure applications.

Usage
1.Initialize Terraform:
terraform init

2.Plan and Apply:
terraform plan
terraform apply
Review the plan and confirm by typing yes when prompted.

3.Access Application:
Once provisioned, access your application using the load balancer's DNS name



Cleanup
To avoid unnecessary charges, destroy the resources when no longer needed:

terraform destroy
Confirm by typing yes when prompted.

