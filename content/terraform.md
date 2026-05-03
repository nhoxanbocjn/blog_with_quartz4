
---
title: "Terraform"
---
A tool that support **IaC** (Infrastructure as Code)

## Infrastructure as Code (IaC)
- IaC is the practice of managing IT infrastructure using configuration files rather than manual, interactive configuration tools.
- Sometimes you forgot what is the configuration of EC2 , S3 storage --> translate it into code is an option to resolve it. 
<!-- - Having a version control, collaboration and deployment repeatedly -->
- Reduces human errors when set up and ensure consistency 

## How it works 
<div align="center">
<pre>
┌────────────────────────────┐
│ 1. Write Configuration     │
│ - Define resources (.tf)   │
│ - Example: EC2, S3, VPC    │
└────────────────────────────┘
│
▼
┌────────────────────────────┐
│ 2. terraform init          │
│ - Download providers       │
│ - Setup backend (state)    │
└────────────────────────────┘
│
▼
┌────────────────────────────┐
│ 3. terraform plan          │
│ - Read current state       │
│ - Compare with desired     │
│ - Show execution plan      │
└────────────────────────────┘
│
▼
┌────────────────────────────┐
│ 4. terraform apply         │
│ - Execute API calls        │
│ - Create / Update / Delete │
│   infrastructure           │
└────────────────────────────┘
│
▼
┌────────────────────────────┐
│ 5. Update State File       │
│ - Save to terraform.tfstate│
│ - Track resource changes   │
└────────────────────────────┘
│
▼
┌────────────────────────────┐
│ 6. Infrastructure Ready    │
│ - Real world = Desired     │
│ - System is in sync        │
└────────────────────────────┘
</pre>
</div>
For configuration 

[Providers]

The provider block configures options that apply to all resources managed by your provider, such as the region to create them in. 

[Data sources]

You can use data blocks to query your cloud provider for information about other resources.

[Resources]

A resource block defines components of your infrastructure.

``` md title="main.tf"
provider "aws" {
  region = "ap-southeast-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "learn-terraform"
  }
}

```

Input variables: parametrize the behavior of your Terraform configuration. 

Output values : access attributes from your Terraform configuration and consume their values with other automation tools or workflows.
> [!note] Terraform State : Terraform state files allows Terraform to compare the current infrastructure with the desired state and apply only the necessary changes

## Terraform vs Ansible

| Feature       | Terraform                                         | Ansible                                              |
|--------------|--------------------------------------------------|------------------------------------------------------|
| Primary Use  | Focuses on setting up and managing infrastructure | Primarily for configuring systems and deploying apps |
| Language     | Uses HCL for infrastructure definitions           | Uses YAML for defining tasks                         |
| Stability    | Ensures resources are created only if necessary   | Requires careful task definition to avoid duplication|
| Execution    | Uses plans and state to manage changes            | Executes tasks immediately (no state tracking)       |
| Cloud Support| Strong multi-cloud support                        | Multi-cloud capable but more system-level focused    |