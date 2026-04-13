# Terraform GitHub Actions CI/CD Plan

## Overview

This plan outlines the implementation of a GitHub Actions workflow for Terraform that:
1. Stores ADC (Application Default Credentials) in GitHub Secrets
2. Automatically runs `terraform plan` when `/plan` comment is added on PR
3. Posts plan output as a PR comment
4. Auto-rejects PRs if plan fails
5. Requires PR approval before apply can be triggered
6. Allows `/apply` comment to trigger `terraform apply`
7. Sends email notifications with apply results

## Architecture

```mermaid
flowchart TD
    A[PR Opened/Updated to master] --> B[Waiting for /plan comment]
    B --> C[/plan comment added]
    C --> D[terraform-plan workflow triggered]
    D --> E[Setup Terraform]
    E --> F[Configure ADC from Secret]
    F --> G[terraform init]
    G --> H[terraform validate]
    H --> I[terraform plan]
    I --> J{Plan Success?}
    J -->|No| K[Post failure comment<br/>Auto-reject PR]
    J -->|Yes| L[Post plan output<br/>to PR comment]
    L --> M[PR requires approval]
    M --> N{PR Approved?}
    N -->|No| O[Wait for approval]
    N -->|Yes| P[/apply comment added]
    P --> Q[terraform-apply workflow]
    Q --> R[terraform apply]
    R --> S[Send email notification]
    S --> T[Update PR comment with apply results]
```

## Workflow Files

### 1. `terraform-plan.yml` - Plan Workflow

**Trigger:** `/plan` comment on PR (repository_dispatch with type `plan`)

**Steps:**
1. Checkout code
2. Setup Terraform
3. Configure ADC (decode base64 secret)
4. Run `terraform init`
5. Run `terraform validate`
6. Run `terraform plan -out=tfplan`
7. Post plan output as PR comment
8. If plan fails → post failure comment and auto-reject PR (request changes)
9. If plan succeeds → post success comment with plan summary

### 2. `terraform-apply.yml` - Apply Workflow

**Trigger:** `/apply` comment on PR (repository_dispatch with type `apply`)

**Prerequisites:**
- PR must be approved

**Steps:**
1. Checkout code
2. Setup Terraform
3. Configure ADC
4. Run `terraform init`
5. Run `terraform apply`
6. Send email notification
7. Update PR comment with apply results

## GitHub Secrets Required

| Secret Name | Description |
|-------------|-------------|
| `GOOGLE_CREDENTIALS` | Base64-encoded ADC JSON file content |
| `SMTP_PASSWORD` | Password for email sending (if using SMTP) |

## GitHub Variables (Optional - for non-sensitive config)

| Variable | Description | Default |
|----------|-------------|---------|
| `TF_PROJECT_ID` | GCP Project ID | `de-devops` |
| `TF_REGION` | GCP Region | `asia-southeast1` |
| `NOTIFICATION_EMAIL` | Email for apply notifications | (to be provided) |

## File Structure

```
.github/
├── workflows/
│   ├── terraform-plan.yml      # Plan workflow (triggered by /plan)
│   ├── terraform-apply.yml     # Apply workflow (triggered by /apply)
│   └── terraform-dispatch.yml   # Helper workflow for dispatch triggers
├── scripts/
│   └── pr-comment.js           # Helper for posting PR comments
└── CODEOWNERS

terraform/
├── main.tf
├── outputs.tf
├── provider.tf
└── variables.tf
```

## Implementation Steps

### Step 1: Create terraform-plan.yml

Create `.github/workflows/terraform-plan.yml`:
- Trigger on: `repository_dispatch` with type `plan`
- Triggered by `/plan` comment via `workflow_dispatch` or `repository_dispatch`
- Jobs: `terraform-plan`
- Use `hashicorp/setup-terraform@v3`
- Decode `GOOGLE_CREDENTIALS` secret and write to file
- Set `GOOGLE_APPLICATION_CREDENTIALS` env var
- Run init, validate, plan
- Post plan output as PR comment using `peter-evans/create-or-update-comment@v4`
- On failure: post error comment and request changes on PR

### Step 2: Create terraform-apply.yml

Create `.github/workflows/terraform-apply.yml`:
- Trigger on: `repository_dispatch` with type `apply`
- Triggered by `/apply` comment
- Check PR approval status first
- Jobs: `terraform-apply`
- Similar setup steps as plan
- Run `terraform apply -auto-approve`
- Send email notification using `dawidd6/action-send-email@v3`
- Update PR comment with results

### Step 3: Create terraform-dispatch.yml (Comment Trigger)

Create `.github/workflows/terraform-dispatch.yml`:
- Trigger on: `issue_comment` (on PRs)
- Parse comment text for `/plan` or `/apply`
- Fire `repository_dispatch` event with appropriate type

### Step 4: Update provider.tf (Optional)

Modify `.github/workflows/` setup to work with GitHub Actions environment:
- The current `file(var.credentials_file)` approach will be replaced with env var

### Step 5: Documentation

Update `README.md` with:
- How to set up GitHub Secrets
- How the workflow operates
- How to trigger plan and apply
- PR approval requirements

## Key Actions/Dependencies

| Action | Purpose |
|--------|---------|
| `hashicorp/setup-terraform@v3` | Setup Terraform CLI |
| `dawidd6/action-send-email@v3` | Send email notifications |
| ` actions/github-script@v7` | Post PR comments, check approvals |
| `peter-evans/create-or-update-comment@v4` | Manage PR comments |

## Security Considerations

1. **ADC in Secrets**: The credentials file content should be base64-encoded before storing as a secret
2. **Least Privilege**: Service account used should have minimal required permissions
3. **No Auto-Apply**: Apply only happens after explicit `/apply` command
4. **PR Approval**: PR must be approved before `/apply` can be triggered
5. **Branch Protection**: `master` branch should have branch protection rules

## Sequence Summary

1. **PR opened** against `master` branch
2. **Developer adds `/plan` comment** → triggers `terraform plan`
3. **Plan succeeds** → plan output posted as PR comment
4. **PR needs approval** → reviewer approves the PR
5. **Developer adds `/apply` comment** → triggers `terraform apply`
6. **Apply completes** → email sent with results

## Pending Items

- [ ] Confirm notification email address
- [ ] Test ADC format (service account key JSON)
- [ ] Verify branch protection rules on `master`
- [ ] Decide on email sending method (SMTP vs GitHub Actions email service)

## Next Steps (for Code mode)

1. Create `.github/workflows/terraform-plan.yml`
2. Create `.github/workflows/terraform-apply.yml`
3. Create `.github/workflows/terraform-dispatch.yml`
4. Create helper scripts if needed
5. Update provider.tf for GitHub Actions compatibility
6. Update documentation
