# Sample Terraform Script for Deploying Solace PubSub+ Event Broker in Azure
## Before you start
You need a Microsoft Azure account and be aware that **applying this template may incure charges to your Azure account**.

## Pre-requisite
Create terraform variable file: `terraform.tfvars`. See the sample file [terraform_tfvars.sample](terraform_tfvars.sample)

## Deploy in AWS
1. Initialize Terraform:
```
terraform init -upgrade
```
2. Review Plan:
```
terraform plan
```
3. Apply Template:
```
terraform apply [-auto-approve]
```

## Remove Instances:
```
terraform destroy
```