# GCP Infrastructure Repository Restructuring Plan

## GitHub Actions Compatibility

The existing GitHub Actions workflows will continue to work without modification because:

1. **Workflows run from repository root** - All three workflows (`terraform-plan.yml`, `terraform-apply.yml`, `terraform-dispatch.yml`) execute `terraform init`, `validate`, and `plan` from the repository root directory.

2. **Root `terraform/` folder remains unchanged** - The following files stay in `terraform/`:
   - `main.tf` (module orchestration)
   - `variables.tf` (global variables)
   - `provider.tf` (provider configuration)
   - `versions.tf` (version constraints)
   - `backend.tf` (backend configuration)

3. **Module-based architecture** - The root `terraform/main.tf` will call modules from `../bigquery/`, `../storage/`, etc., which Terraform handles automatically.

4. **No workflow path changes needed** - Since workflows don't hardcode specific file paths and use standard Terraform commands, no changes are required.

---

## Objective

## Objective
Restructure the repository to follow BigQuery and GCS best practices with a scalable, modular folder structure that enables extensibility without modifying existing configurations.

---

## Implementation Scope

**Phase 1 (Current):** Create BigQuery tables and Storage buckets only
**Phase 2 (Future):** Add Pub/Sub, Dataflow, Composer as needed

## Target Repository Structure

```plaintext
de-devops-gcp/
├── .github/
├── .vscode/
├── plans/
│   └── bigquery-gcs-restructuring-plan.md
│
├── terraform/                           # Root Terraform orchestration
│   ├── backend.tf                        # Terraform backend configuration
│   ├── main.tf                           # Module orchestration (calls all resource modules)
│   ├── outputs.tf                        # Global outputs
│   ├── provider.tf                       # Provider configuration
│   ├── variables.tf                      # Global variables
│   └── versions.tf                       # Terraform & provider version constraints
│
├── bigquery/                             # BigQuery resources (one folder per dataset)
│   ├── _datasets/                        # Dataset-level shared resources
│   │   └── dataset_variables.tf.example
│   │
│   ├── dataset_analytics/                # Example: analytics dataset
│   │   ├── dataset.tf                    # Dataset resource
│   │   ├── variables.tf                  # Dataset-level variables
│   │   │
│   │   └── tables/                       # Tables within this dataset
│   │       ├── table_users/              # Example: users table
│   │       │   ├── table.tf              # Table resource definition
│   │       │   ├── variables.tf          # Table-specific variables
│   │       │   └── schema.json           # Table schema definition
│   │       │
│   │       └── table_events/
│   │           ├── table.tf
│   │           ├── variables.tf
│   │           └── schema.json
│   │
│   └── dataset_raw/                      # Example: raw dataset
│       ├── dataset.tf
│       ├── variables.tf
│       └── tables/
│           └── table_logs/
│               ├── table.tf
│               ├── variables.tf
│               └── schema.json
│
├── storage/                             # GCS resources (one folder per bucket)
│   ├── _bucket_modules/                  # Shared bucket-level resources
│   │   └── bucket_variables.tf.example
│   │
│   ├── bucket_data_lake/                 # Example: data lake bucket
│   │   ├── bucket.tf                     # Bucket resource
│   │   ├── variables.tf                  # Bucket-specific variables
│   │   └── iam.tf                        # Bucket-level IAM bindings
│   │
│   └── bucket_configs/                   # Example: configs bucket
│       ├── bucket.tf
│       ├── variables.tf
│       └── iam.tf
│
├── pubsub/                              # Placeholder - add topics as needed
├── dataflow/                            # Placeholder - add jobs as needed
├── composer/                            # Placeholder - add environments as needed
│
└── README.md
```

---

## BigQuery Structure Detail

### Pattern: `bigquery/<dataset_name>/tables/<table_name>/`

```
bigquery/
└── dataset_analytics/
    ├── dataset.tf          # Optional: explicit dataset resource
    ├── variables.tf        # Dataset variables (dataset_id, description, location)
    │
    └── tables/
        └── table_users/
            ├── table.tf          # BigQuery table resource
            ├── variables.tf      # Table configuration variables
            └── schema.json       # Schema definition
```

### Example: `schema.json`

```json
{
  "table_name": "users",
  "dataset": "analytics",
  "partitioning": {
    "type": "TIME",
    "field": "created_at"
  },
  "clustering": ["country", "status"],
  "schema": [
    {
      "name": "user_id",
      "type": "STRING",
      "mode": "REQUIRED",
      "description": "Unique user identifier"
    },
    {
      "name": "email",
      "type": "STRING",
      "mode": "REQUIRED",
      "description": "User email address"
    },
    {
      "name": "created_at",
      "type": "TIMESTAMP",
      "mode": "REQUIRED",
      "description": "Account creation timestamp"
    },
    {
      "name": "country",
      "type": "STRING",
      "mode": "NULLABLE",
      "description": "User country code"
    },
    {
      "name": "status",
      "type": "STRING",
      "mode": "NULLABLE",
      "description": "Account status (active/inactive)"
    }
  ]
}
```

### Example: `variables.tf` (Table)

```hcl
variable "table_users" {
  description = "Configuration for users table in analytics dataset"

  type = object({
    dataset_id    = string
    table_id      = string
    partitioning  = optional(any)
    clustering    = optional(list(string))
    schema_file   = string
    deletion_protection = bool
  })

  default = {
    dataset_id    = "analytics"
    table_id      = "users"
    schema_file   = "schema.json"
    deletion_protection = true
  }
}
```

### Example: `table.tf`

```hcl
locals {
  table_users_config = var.table_users
}

resource "google_bigquery_table" "users" {
  project            = var.project_id
  dataset_id         = local.table_users_config.dataset_id
  table_id           = local.table_users_config.table_id
  deletion_protection = local.table_users_config.deletion_protection

  dynamic "time_partitioning" {
    for_each = local.table_users_config.partitioning != null ? [local.table_users_config.partitioning] : []
    content {
      type = time_partitioning.value.type
      field = time_partitioning.value.field
    }
  }

  dynamic "clustering" {
    for_each = local.table_users_config.clustering != null ? local.table_users_config.clustering : []
    content {
      fields = clustering.value
    }
  }

  schema = jsondecode(file("${path.module}/schema.json")).schema
}
```

---

## GCS Structure Detail

### Pattern: `storage/<bucket_name>/`

```
storage/
└── bucket_data_lake/
    ├── bucket.tf          # GCS bucket resource
    ├── variables.tf      # Bucket configuration
    ├── iam.tf            # Bucket-level IAM
    │
    └── objects/          # Objects/folders within bucket
        └── lifecycle_rule/
            ├── lifecycle.tf
            └── variables.tf
```

### Example: `variables.tf` (Bucket)

```hcl
variable "bucket_data_lake" {
  description = "Configuration for data lake bucket"

  type = object({
    name          = string
    location      = string
    storage_class = string
    labels        = map(string)
    iam_members = list(object({
      role   = string
      member = string
    }))
    lifecycle_rules = optional(list(object({
      action   = string
      condition = map(any)
    })))
  })

  default = {
    name          = "de-devops-data-lake"
    location      = "asia-southeast1"
    storage_class = "STANDARD"
    labels        = {}
    iam_members   = []
  }
}
```

### Example: `bucket.tf`

```hcl
locals {
  bucket_config = var.bucket_data_lake
}

resource "google_storage_bucket" "data_lake" {
  name         = local.bucket_config.name
  location     = local.bucket_config.location
  storage_class = local.bucket_config.storage_class
  labels       = local.bucket_config.labels

  uniform_bucket_level_access = true

  dynamic "lifecycle_rule" {
    for_each = local.bucket_config.lifecycle_rules != null ? local.bucket_config.lifecycle_rules : []
    content {
      action {
        type = lifecycle_rule.value.action
      }
      condition {
        for_each = lifecycle_rule.value.condition
        content {
          for_each = condition.value
        }
      }
    }
  }
}
```

### Example: `iam.tf` (Bucket-level)

```hcl
locals {
  bucket_iam_config = var.bucket_data_lake
}

resource "google_storage_bucket_iam_member" "data_lake_binding" {
  for_each = { for idx, binding in local.bucket_iam_config.iam_members : idx => binding }

  bucket = google_storage_bucket.data_lake.name
  role   = each.value.role
  member = each.value.member
}
```

---

## Root Terraform Module Orchestration

### `terraform/main.tf`

```hcl
module "bigquery_analytics" {
  source = "../bigquery/dataset_analytics"

  project_id = var.project_id
  region     = var.region
}

module "bigquery_raw" {
  source = "../bigquery/dataset_raw"

  project_id = var.project_id
  region     = var.region
}

module "storage_data_lake" {
  source = "../storage/bucket_data_lake"

  project_id = var.project_id
}

module "storage_configs" {
  source = "../storage/bucket_configs"

  project_id = var.project_id
}
```

---

## Extensibility Pattern

### Adding a New BigQuery Dataset

1. Create folder: `bigquery/dataset_new_dataset/`
2. Create `tables/` subfolder structure
3. Add `variables.tf` with dataset configuration
4. Add `dataset.tf` with dataset resource
5. Add module call in `terraform/main.tf`

```hcl
# No modification to existing structure required
# Simply add new module:
module "bigquery_new_dataset" {
  source = "../bigquery/dataset_new_dataset"
  project_id = var.project_id
  region     = var.region
}
```

### Adding a New BigQuery Table

1. Create folder: `bigquery/dataset_existing/tables/table_new_table/`
2. Add `table.tf`, `variables.tf`, `schema.json`
3. Update parent dataset's `tables.tf` to include new table module

### Adding a New GCS Bucket

1. Create folder: `storage/bucket_new_bucket/`
2. Add `bucket.tf`, `variables.tf`, `iam.tf` as needed
3. Add module call in `terraform/main.tf`

---

## Key Design Principles

| Principle | Implementation |
|-----------|----------------|
| **One folder per resource** | Each BigQuery dataset, table, or GCS bucket has its own folder |
| **Self-contained configuration** | Each folder contains all files needed for that resource |
| **Hierarchical structure** | Resources nested logically (dataset → tables, bucket → objects) |
| **Extensible without modification** | Add new resources by creating new folders, not editing existing files |
| **Consistent naming** | Folder names match resource names: `bucket_x` → `bucket_x/` |
| **Variable-driven configuration** | Schema as JSON, IAM as variables, resources as TF files |

---

## Migration Steps

1. **Backup existing `terraform/` contents**
2. **Create new directory structure**
3. **Move service accounts and project-level IAM to `terraform/`**
4. **Create example BigQuery dataset with one table**
5. **Create example GCS bucket with IAM**
6. **Update root `main.tf` to orchestrate all modules**
7. **Test with `terraform plan`**
8. **Document patterns in README**
9. **Commit and verify**

---

## Files to Create (Phase 1 - BigQuery & Storage Only)

### Terraform Root Files
| File Path | Purpose |
|-----------|---------|
| `terraform/backend.tf` | Terraform backend config |
| `terraform/versions.tf` | Version constraints |

### BigQuery: dataset_analytics
| File Path | Purpose |
|-----------|---------|
| `bigquery/dataset_analytics/dataset.tf` | Dataset resource |
| `bigquery/dataset_analytics/variables.tf` | Dataset variables |
| `bigquery/dataset_analytics/tables/table_users/table.tf` | Users table resource |
| `bigquery/dataset_analytics/tables/table_users/variables.tf` | Users table variables |
| `bigquery/dataset_analytics/tables/table_users/schema.json` | Users table schema |
| `bigquery/dataset_analytics/tables/table_events/table.tf` | Events table resource |
| `bigquery/dataset_analytics/tables/table_events/variables.tf` | Events table variables |
| `bigquery/dataset_analytics/tables/table_events/schema.json` | Events table schema |

### BigQuery: dataset_raw
| File Path | Purpose |
|-----------|---------|
| `bigquery/dataset_raw/dataset.tf` | Dataset resource |
| `bigquery/dataset_raw/variables.tf` | Dataset variables |
| `bigquery/dataset_raw/tables/table_logs/table.tf` | Logs table resource |
| `bigquery/dataset_raw/tables/table_logs/variables.tf` | Logs table variables |
| `bigquery/dataset_raw/tables/table_logs/schema.json` | Logs table schema |

### GCS Buckets
| File Path | Purpose |
|-----------|---------|
| `storage/bucket_data_lake/bucket.tf` | Data lake bucket |
| `storage/bucket_data_lake/variables.tf` | Data lake variables |
| `storage/bucket_data_lake/iam.tf` | Data lake IAM |
| `storage/bucket_configs/bucket.tf` | Configs bucket |
| `storage/bucket_configs/variables.tf` | Configs variables |
| `storage/bucket_configs/iam.tf` | Configs IAM |

### Templates
| File Path | Purpose |
|-----------|---------|
| `bigquery/_datasets/variables.tf.example` | Dataset template |
| `storage/_bucket_modules/variables.tf.example` | Bucket template |

---

## Verification Commands

```bash
# Validate structure
find . -type d -name "tables" -o -name "objects" | head -20

# Test Terraform
cd terraform && terraform validate
terraform plan

# List all modules
grep -r "module \"" terraform/*.tf
```
