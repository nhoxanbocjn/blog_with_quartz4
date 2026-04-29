
---
title: "Terraform"
---
A tool that support **IaC** (Infrastructure as Code)

## Infrastructure as Code (IaC)
- IaC is the practice of managing IT infrastructure using configuration files rather than manual, interactive configuration tools.
- Sometimes you forgot what is the configuration of EC2 , S3 storage --> translate it into code is an option to resolve it. 
- Having a version control, collaboration and deployment repeatedly
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