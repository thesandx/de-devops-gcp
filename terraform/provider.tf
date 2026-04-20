provider "google" {
  # Uses GOOGLE_APPLICATION_CREDENTIALS environment variable when set (GitHub Actions)
  # Falls back to credentials_file variable for local development
  credentials = var.credentials_file != "" ? file(var.credentials_file) : null
  project     = var.project_id
  region      = var.region
}

variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "de-devops"
}

variable "region" {
  description = "The region to deploy resources to ex - singapore"
  type        = string
  default     = "asia-southeast1"
}

variable "credentials_file" {
  description = "Path to the service account key file i.e adc file. Can be empty if GOOGLE_APPLICATION_CREDENTIALS is set (e.g., in GitHub Actions)"
  type        = string
  default     = "" # Empty by default - GitHub Actions will use GOOGLE_APPLICATION_CREDENTIALS env var
}

# ============================================
# BigQuery Dataset Configurations
# ============================================

variable "dataset_analytics" {
  description = "Configuration for analytics dataset"
  type = object({
    dataset_id  = string
    description = string
    location    = string
    labels      = map(string)
  })

  default = {
    dataset_id  = "analytics"
    description = "Analytics dataset for business metrics and user data"
    location    = "asia-southeast1"
    labels = {
      environment = "prod"
      team        = "data"
    }
  }
}

variable "dataset_raw" {
  description = "Configuration for raw dataset"
  type = object({
    dataset_id  = string
    description = string
    location    = string
    labels      = map(string)
  })

  default = {
    dataset_id  = "raw"
    description = "Raw dataset for staging and landing data"
    location    = "asia-southeast1"
    labels = {
      environment = "prod"
      team        = "data"
    }
  }
}

# ============================================
# GCS Bucket Configurations
# ============================================

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
      action_type    = string
      age            = optional(number)
      created_before = optional(string)
    })))
  })

  default = {
    name          = "de-devops-data-lake"
    location      = "asia-southeast1"
    storage_class = "STANDARD"
    labels = {
      environment = "prod"
      team        = "data"
    }
    iam_members = []
  }
}

variable "bucket_configs" {
  description = "Configuration for configs bucket"
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
      action_type    = string
      age            = optional(number)
      created_before = optional(string)
    })))
  })

  default = {
    name          = "de-devops-configs"
    location      = "asia-southeast1"
    storage_class = "STANDARD"
    labels = {
      environment = "prod"
      team        = "platform"
    }
    iam_members = []
  }
}

variable "bucket_raw_batch" {
  description = "Configuration for raw batch ingestion bucket"
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
      action_type    = string
      age            = optional(number)
      created_before = optional(string)
    })))
  })

  default = {
    name          = "de-devops-raw-batch"
    location      = "asia-southeast1"
    storage_class = "STANDARD"
    labels = {
      environment = "prod"
      team        = "data"
    }
    iam_members = []
  }
}

variable "bucket_raw_streaming" {
  description = "Configuration for raw streaming ingestion bucket"
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
      action_type    = string
      age            = optional(number)
      created_before = optional(string)
    })))
  })

  default = {
    name          = "de-devops-raw-streaming"
    location      = "asia-southeast1"
    storage_class = "STANDARD"
    labels = {
      environment = "prod"
      team        = "data"
    }
    iam_members = []
  }
}

# ============================================
# BigQuery Table Configurations - Analytics
# ============================================

variable "table_users" {
  description = "Configuration for users table in analytics dataset"
  type = object({
    dataset_id          = string
    table_id            = string
    partitioning        = optional(any)
    clustering          = optional(list(string))
    schema_file         = string
    deletion_protection = bool
  })

  default = {
    dataset_id          = "analytics"
    table_id            = "users"
    schema_file         = "schema.json"
    deletion_protection = true
  }
}

variable "table_events" {
  description = "Configuration for events table in analytics dataset"
  type = object({
    dataset_id          = string
    table_id            = string
    partitioning        = optional(any)
    clustering          = optional(list(string))
    schema_file         = string
    deletion_protection = bool
  })

  default = {
    dataset_id          = "analytics"
    table_id            = "events"
    schema_file         = "schema.json"
    deletion_protection = true
  }
}

# ============================================
# BigQuery Table Configurations - Raw
# ============================================

variable "table_logs" {
  description = "Configuration for logs table in raw dataset"
  type = object({
    dataset_id          = string
    table_id            = string
    partitioning        = optional(any)
    clustering          = optional(list(string))
    schema_file         = string
    deletion_protection = bool
  })

  default = {
    dataset_id          = "raw"
    table_id            = "logs"
    schema_file         = "schema.json"
    deletion_protection = true
  }
}
