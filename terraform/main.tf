# Service Account for Data Pipeline
resource "google_service_account" "data_pipeline" {
  account_id   = "de-devops-data-pipeline"
  display_name = "Data Pipeline Service Account"
}

# Assign BigQuery Job User role to the data pipeline service account
resource "google_project_iam_member" "data_pipeline_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.data_pipeline.email}"
}

# Assign BigQuery Data Viewer role to the data pipeline service account
resource "google_project_iam_member" "data_pipeline_bq_data_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.data_pipeline.email}"
}

# Assign BigQuery Data Editor role to the user (allows read/write but not delete)
resource "google_project_iam_member" "user_bq_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "user:nikhila.nethikunta@gmail.com"
}

# Assign BigQuery User role to the user (allows to run queries)
resource "google_project_iam_member" "user_bq_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "user:nikhila.nethikunta@gmail.com"
}

# Assign Storage Object User role to the user (allows read/write but not delete)
resource "google_project_iam_member" "user_storage_object_user" {
  project = var.project_id
  role    = "roles/storage.objectUser"
  member  = "user:nikhila.nethikunta@gmail.com"
}

# ============================================
# BigQuery Datasets
# ============================================

module "bigquery_dataset_analytics" {
  source = "../bigquery/dataset_analytics"

  dataset_id  = var.dataset_analytics.dataset_id
  description = var.dataset_analytics.description
  location    = var.dataset_analytics.location
  labels      = var.dataset_analytics.labels
}

module "bigquery_dataset_raw" {
  source = "../bigquery/dataset_raw"

  dataset_id  = var.dataset_raw.dataset_id
  description = var.dataset_raw.description
  location    = var.dataset_raw.location
  labels      = var.dataset_raw.labels
}

# ============================================
# BigQuery Tables - Analytics Dataset
# ============================================

module "bigquery_table_users" {
  source = "../bigquery/dataset_analytics/tables/table_users"

  dataset_id = var.dataset_analytics.dataset_id
}

module "bigquery_table_events" {
  source = "../bigquery/dataset_analytics/tables/table_events"

  dataset_id = var.dataset_analytics.dataset_id
}

# ============================================
# BigQuery Tables - Raw Dataset
# ============================================

module "bigquery_table_logs" {
  source = "../bigquery/dataset_raw/tables/table_logs"

  dataset_id = var.dataset_raw.dataset_id
}

# ============================================
# GCS Buckets
# ============================================

module "storage_bucket_data_lake" {
  source = "../storage/bucket_data_lake"

  bucket_name   = var.bucket_data_lake.name
  location      = var.bucket_data_lake.location
  storage_class = var.bucket_data_lake.storage_class
  bucket_labels = var.bucket_data_lake.labels
  iam_members   = var.bucket_data_lake.iam_members
}

module "storage_bucket_configs" {
  source = "../storage/bucket_configs"

  bucket_name   = var.bucket_configs.name
  location      = var.bucket_configs.location
  storage_class = var.bucket_configs.storage_class
  bucket_labels = var.bucket_configs.labels
  iam_members   = var.bucket_configs.iam_members
}
