# Changelog

## Initial Setup

- Created repo from the template repository
- Created ADC file and added in terraform folder and updated path (refer to README.md inside terraform folder)
- Added SA details in the terraform configuration

## Terraform Operations

The following commands were executed inside the terraform folder:

```bash
terraform fmt -check         # check formatting (esp. in CI)
terraform init               # initialize directory
terraform validate           # validate syntax
terraform plan -out=tfplan   # plan and save
terraform apply tfplan       # apply the saved plan
```

#todo
ETL pipeline system design HLD and LLD
which all features and resources we will need
and then proceed one by one
can use 
