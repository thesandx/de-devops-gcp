# Terraform GCP Infrastructure

This directory contains Terraform configuration files to set up infrastructure on Google Cloud Platform (GCP). The configuration creates a service account, a Cloud Storage bucket, and a BigQuery dataset.

## File Structure

### main.tf
This file contains the main resource definitions:
- `google_service_account.ci`: Creates a service account for CI/CD operations
- `google_storage_bucket.tfstate_bucket`: Creates a Cloud Storage bucket (potentially for storing Terraform state)
- `google_bigquery_dataset.dataset`: Creates a BigQuery dataset

### provider.tf
This file configures the Terraform provider:
- Specifies the Google Cloud provider
- Sets the required provider version
- Configures authentication using a service account key file
- Sets the GCP project and region
- **Also contains all variable definitions** (since there is no separate variables.tf)

### outputs.tf
This file defines the output values that will be displayed after applying the configuration:
- `service_account_email`: The email address of the created service account
- `bucket_name`: The name of the created Cloud Storage bucket
- `bucket_url`: The URL of the created Cloud Storage bucket
- `bigquery_dataset`: The ID of the created BigQuery dataset

## Using .tfvars Files

`.tfvars` files (Terraform variable files) are used to provide values for variables defined in your Terraform configuration. They allow you to separate configuration from code, making it easier to manage different environments (dev, staging, prod) and keep sensitive values out of version control.

### Benefits of .tfvars Files
1. **Environment Separation**: Create different `.tfvars` files for each environment (e.g., `dev.tfvars`, `prod.tfvars`)
2. **Security**: Keep sensitive values like credentials out of your main Terraform files
3. **Reusability**: Use the same Terraform code with different variable values
4. **Git Ignored**: `.gitignore` already excludes `*.tfvars` and `*.tfvars.json` files

### How to Use .tfvars in This Project

1. **Create a `terraform.tfvars` file** (or copy the example):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit the `terraform.tfvars` file** with your specific values:
   - Update `project_id`, `region`, `credentials_file`
   - Modify dataset and bucket configurations as needed
   - Add IAM members, labels, etc.

3. **Run Terraform with the `.tfvars` file**:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```
   Or simply `terraform plan` (Terraform automatically loads `terraform.tfvars` if present)

4. **Use multiple environments**:
   ```bash
   terraform plan -var-file="dev.tfvars"
   terraform apply -var-file="dev.tfvars"
   ```

### Variable File Precedence
Terraform loads variables in this order (later overrides earlier):
1. Environment variables (`TF_VAR_name`)
2. `terraform.tfvars` (if present)
3. `terraform.tfvars.json` (if present)
4. Any `*.auto.tfvars` or `*.auto.tfvars.json` files
5. Command-line `-var` or `-var-file` arguments

### Example Variable Files
- `terraform.tfvars.example`: Example configuration with all variables (safe to commit)
- `terraform.tfvars`: Your actual configuration (should be kept private)

## Running Terraform

### Prerequisites
1. Install Terraform (version 1.0.0 or later recommended)
2. Set up a GCP account and project
3. Create a service account with appropriate permissions
4. Download the service account key file (JSON) `<gcloud auth application-default login>`
5. It will save file in `/Users/sandeepkumarjha/.config/gcloud/application_default_credentials.json`
6. `cat <above location>` copy content and create a new json file `<de-devops-adc.json>` inside terraform folder
7. Paste the json content from above and update credentials_file path in variables.tf

### Configuration
Before running Terraform, update the `variables.tf` file or create a `terraform.tfvars` file with your specific values:

```hcl
project_id       = "your-gcp-project-id"
region           = "your-preferred-region"
bucket_name      = "your-unique-bucket-name"
credentials_file = "/path/to/your/service-account-key.json"
bigquery_dataset = "your_dataset_name"
```

### Commands

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```
   This command initializes the working directory containing the Terraform configuration files.

2. **Plan the changes**:
   ```bash
   terraform plan
   ```
   This command creates an execution plan, showing what actions Terraform will take to apply the current configuration.

3. **Apply the changes**:
   ```bash
   terraform apply
   ```
   This command applies the changes required to reach the desired state of the configuration. You'll be prompted to confirm before any changes are made.

4. **Destroy the infrastructure** (when no longer needed):
   ```bash
   terraform destroy
   ```
   This command destroys all resources created by the Terraform configuration. Use with caution!

## Best Practices for .tfvars in CI/CD

1. **Never commit sensitive `.tfvars` files** - Use CI/CD secret variables instead
2. **Use environment-specific files** - Create `dev.tfvars`, `staging.tfvars`, `prod.tfvars`
3. **Combine with Terraform Cloud/Enterprise** - Use workspace variables for sensitive data
4. **Use `*.auto.tfvars` for automatic loading** - Files named `*.auto.tfvars` are loaded automatically
5. **Validate variable files** - Use `terraform validate` to check syntax

### GitHub Actions Integration
In your GitHub Actions workflow, you can pass variables via environment variables:
```yaml
env:
  TF_VAR_project_id: ${{ secrets.GCP_PROJECT_ID }}
  TF_VAR_credentials_file: ""
```

Or use a secret `.tfvars` file stored as a secret and decoded at runtime.

## Notes
- Make sure your service account has the necessary permissions to create the resources defined in the configuration.
- The Cloud Storage bucket name must be globally unique across all of GCP.
- Remember to keep your service account key file secure and never commit it to version control.
- `.tfvars` files are ignored by `.gitignore` to prevent accidental commits of sensitive data.
