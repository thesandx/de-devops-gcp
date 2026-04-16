# Terraform CI/CD Setup Guide

This guide outlines the steps required to set up and maintain the automated Terraform CI/CD pipeline using GitHub Actions. The pipeline allows developers to trigger Terraform plans and applies directly from Pull Request comments (`/plan` and `/apply`).

## Table of Contents
1. [GCP Setup: Terraform State in GCS Bucket](#1-gcp-setup-terraform-state-in-gcs-bucket)
2. [Terraform Backend Sync to GCS](#2-terraform-backend-sync-to-gcs)
3. [GitHub Authentication Setup](#3-github-authentication-setup)
   - [PAT Generation](#pat-generation)
   - [GitHub Apps (Alternative)](#github-apps-alternative)
4. [GitHub Action Settings](#4-github-action-settings)
5. [GitHub Actions Workflows](#5-github-actions-workflows)
6. [Local Development & ADC Fallback](#6-local-development--adc-fallback)
7. [Troubleshooting: Terraform Import (Already Exists Error)](#7-troubleshooting-terraform-import-already-exists-error)

---

## 1. GCP Setup: Terraform State in GCS Bucket

To ensure state consistency across multiple developers and CI/CD pipelines, Terraform state must be stored remotely in a Google Cloud Storage (GCS) bucket.

1. **Create a GCS Bucket**:
   Create a bucket in your GCP project specifically for Terraform state. Enable versioning to keep backups of your state files.
   ```bash
   gsutil mb -p <YOUR_PROJECT_ID> -l <REGION> gs://<YOUR_STATE_BUCKET_NAME>
   gsutil versioning set on gs://<YOUR_STATE_BUCKET_NAME>
   ```

2. **Configure `backend.tf`**:
   Update your `terraform/backend.tf` to point to the new GCS bucket.
   ```hcl
   terraform {
     backend "gcs" {
       bucket = "<YOUR_STATE_BUCKET_NAME>"
       prefix = "terraform/state"
     }
   }
   ```

## 2. Terraform Backend Sync to GCS

If you have been running Terraform locally and have a `terraform.tfstate` file, you need to migrate it to the GCS bucket.

1. Ensure your `backend.tf` is configured as shown above.
2. Run the initialization command:
   ```bash
   terraform init
   ```
3. Terraform will detect the local state and ask if you want to copy it to the new backend. Type `yes`.
4. Once synced, you can safely delete your local `terraform.tfstate` and `terraform.tfstate.backup` files.

## 3. GitHub Authentication Setup

To allow GitHub Actions to interact with PRs (post comments, check approvals) and trigger workflows, you need proper authentication.

### PAT Generation (Personal Access Token)
1. Go to your GitHub Profile Settings -> Developer settings -> Personal access tokens -> Tokens (classic).
2. Click **Generate new token (classic)**.
3. Give it a descriptive name (e.g., `Terraform CI/CD Bot`).
4. Select the following scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
5. Generate the token and copy it immediately.

### GitHub Apps (Alternative & Recommended)
Instead of a PAT tied to a user account, you can create a GitHub App for your organization/repository. This provides better security and higher rate limits.
1. Go to Settings -> Developer settings -> GitHub Apps -> New GitHub App.
2. Grant it permissions for Repository Contents (Read), Pull Requests (Read/Write), and Issues (Read/Write).
3. Install the App on your repository.
4. Generate a Private Key for the App and note the App ID.

## 4. GitHub Action Settings

Configure your repository settings to allow the workflows to run successfully.

1. **Workflow Permissions**:
   - Go to Repository Settings -> Actions -> General.
   - Under **Workflow permissions**, select **Read and write permissions**.
   - Check **Allow GitHub Actions to create and approve pull requests**.

2. **Repository Secrets**:
   Go to Repository Settings -> Secrets and variables -> Actions -> New repository secret.
   - `GOOGLE_CREDENTIALS`: The JSON key i.e adc of your GCP Service Account.
     ```bash
     cat service-account-key.json
     ```
   - `PAT_TOKEN`: The Personal Access Token generated in Step 3 (if using PAT).
   - `APP_ID` & `APP_PRIVATE_KEY`: If using a GitHub App instead of a PAT.

3. **Repository Variables**:
   Go to Repository Settings -> Secrets and variables -> Actions -> Variables.
   - `TF_PROJECT_ID`: Your GCP Project ID.
   - `TF_REGION`: Your default GCP region.

## 5. GitHub Actions Workflows

The CI/CD pipeline consists of three main workflows located in `.github/workflows/`:

1. **`terraform-dispatch.yml`**:
   - Listens for `issue_comment` events on Pull Requests.
   - Parses the comment for `/plan` or `/apply`.
   - Triggers a `repository_dispatch` event to start the respective workflow.

2. **`terraform-plan.yml`**:
   - Triggered by the `/plan` comment.
   - Checks out the code, sets up Terraform, and configures GCP credentials.
   - Runs `terraform init`, `terraform validate`, and `terraform plan`.
   - Posts the plan output as a comment on the PR.
   - If the plan fails, it auto-rejects the PR.

3. **`terraform-apply.yml`**:
   - Triggered by the `/apply` comment.
   - **Prerequisite**: The PR must be approved by a reviewer.
   - Runs `terraform apply -auto-approve`.
   - Posts the apply results back to the PR comment.

## 6. Local Development & ADC Fallback

When developing locally, you shouldn't use the base64-encoded service account key. Instead, use Application Default Credentials (ADC).

1. **Login with GCP**:
   Run the following command to authenticate your local machine with GCP:
   ```bash
   gcloud auth application-default login
   ```
   This creates a local ADC file (usually at `~/.config/gcloud/application_default_credentials.json`).

2. **Terraform Provider Configuration**:
   Ensure your `provider.tf` does not hardcode the credentials file path. It should rely on the environment or ADC.
   ```hcl
   provider "google" {
     project = var.project_id
     region  = var.region
     # Do NOT set credentials = file(...) here.
     # Terraform will automatically find the ADC file locally,
     # and GitHub Actions will use the GOOGLE_APPLICATION_CREDENTIALS env var.
   }
   ```

## 7. Troubleshooting: Terraform Import (Already Exists Error)

Sometimes, a resource might be created manually in the GCP Console, or the Terraform state might get out of sync. When you run `terraform apply`, you might encounter an error like:
`Error: resource ... already exists`

To fix this, you need to import the existing resource into your Terraform state.

1. Identify the resource type and name in your Terraform code (e.g., `google_storage_bucket.my_bucket`).
2. Identify the GCP resource ID (usually the project/region/name, check the Terraform provider documentation for the exact format).
3. Run the import command locally (ensure you are authenticated via ADC):
   ```bash
   terraform import google_storage_bucket.my_bucket <GCP_RESOURCE_ID>
   ex; -
   cd terraform && terraform import module.bigquery_dataset_analytics.google_bigquery_dataset.analytics de-devops/analytics


   cd terraform && terraform import module.bigquery_dataset_raw.google_bigquery_dataset.raw de-devops/raw

   cd terraform && terraform import module.storage_bucket_configs.google_storage_bucket.configs de-devops-configs
   ```
4. After a successful import, run `terraform plan` to ensure your code matches the actual infrastructure state. If there are differences, update your Terraform code accordingly.
5. Commit and push the changes.
