# de-devops-template

This repository contains Terraform configurations for managing GCP resources with automated CI/CD via GitHub Actions.

## Architecture

The CI/CD pipeline uses GitHub Actions to manage terraform operations with the following workflow:

```
PR Opened → /plan comment → Terraform Plan runs → Output posted to PR
                                                          ↓
                                              PR needs approval
                                                          ↓
                                         /apply comment → Terraform Apply → Email sent
```

## Quick Start

### 1. Set Up GitHub Secrets

Before using the workflow, you need to configure the following in your GitHub repository:

1. Go to **Settings → Secrets and variables → Actions**
2. Add a new **Repository secret**:
   - Name: `GOOGLE_CREDENTIALS`
   - Value: Base64-encoded service account JSON key file

To encode your ADC file:
```bash
base64 -i de-devops-adc.json | tr -d '\n'
```

### 2. Set Up GitHub Variables (Optional)

Configure these for non-sensitive configuration:

1. Go to **Settings → Variables → Actions**
2. Add the following variables:

| Variable | Value | Description |
|----------|-------|-------------|
| `TF_PROJECT_ID` | `de-devops` | GCP Project ID |
| `TF_REGION` | `asia-southeast1` | GCP Region |
| `NOTIFICATION_EMAIL` | `your-email@example.com` | Email for apply notifications |

### 3. Enable Branch Protection

Ensure `master` branch has protection rules enabled requiring PR approval before merge.

## Workflow Usage

### Running Terraform Plan

1. Open a PR targeting `master` branch
2. Comment `/plan` on the PR
3. The workflow will automatically:
   - Run `terraform init`
   - Run `terraform validate`
   - Run `terraform plan`
   - Post the plan output as a PR comment
4. If the  plan fails, the PR will be auto-rejected

### Running Terraform Apply

1. Ensure the plan has run successfully
2. Get the PR approved by a reviewer
3. Comment `/apply` on the PR
4. The workflow will:
   - Verify PR is approved
   - Run `terraform apply`
   - Send email notification with results
   - Post apply results to PR

## Workflow Files

| File | Description |
|------|-------------|
| [`.github/workflows/terraform-plan.yml`](.github/workflows/terraform-plan.yml) | Runs terraform plan on `/plan` command |
| [`.github/workflows/terraform-apply.yml`](.github/workflows/terraform-apply.yml) | Runs terraform apply on `/apply` command |
| [`.github/workflows/terraform-dispatch.yml`](.github/workflows/terraform-dispatch.yml) | Handles comment dispatching |
| [`.github/scripts/pr-comment.js`](.github/scripts/pr-comment.js) | Helper script for PR comments |

## Terraform Configuration

The terraform configuration is in the [`terraform/`](terraform/) directory:

| File | Description |
|------|-------------|
| [`main.tf`](terraform/main.tf) | Main resource definitions |
| [`provider.tf`](terraform/provider.tf) | GCP provider configuration |
| [`variables.tf`](terraform/variables.tf) | Input variables |
| [`outputs.tf`](terraform/outputs.tf) | Output values |

## Local Development

For local development, ensure you have:
- Terraform installed
- GCP credentials configured (e.g., `GOOGLE_APPLICATION_CREDENTIALS` or `gcloud auth login`)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Security Considerations

- **Never commit service account keys** to the repository
- **Use GitHub Secrets** for sensitive credentials
- **PR approval required** before apply can run
- **Branch protection** should be enabled on `master`
