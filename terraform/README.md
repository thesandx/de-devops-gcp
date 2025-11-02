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

### variables.tf
This file defines the input variables used in the configuration:
- `project_id`: The ID of your GCP project
- `region`: The GCP region to deploy resources to (default: asia-southeast1)
- `bucket_name`: The name for the Cloud Storage bucket
- `credentials_file`: Path to your service account key file
- `bigquery_dataset`: The ID for the BigQuery dataset

### outputs.tf
This file defines the output values that will be displayed after applying the configuration:
- `service_account_email`: The email address of the created service account
- `bucket_name`: The name of the created Cloud Storage bucket
- `bucket_url`: The URL of the created Cloud Storage bucket
- `bigquery_dataset`: The ID of the created BigQuery dataset

## Running Terraform

### Prerequisites
1. Install Terraform (version 1.0.0 or later recommended)
2. Set up a GCP account and project
3. Create a service account with appropriate permissions
4. Download the service account key file (JSON)

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

## Notes
- Make sure your service account has the necessary permissions to create the resources defined in the configuration.
- The Cloud Storage bucket name must be globally unique across all of GCP.
- Remember to keep your service account key file secure and never commit it to version control.
