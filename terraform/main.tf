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

# Create custom role for BigQuery without delete permissions
resource "google_project_iam_custom_role" "bigquery_no_delete" {
  role_id     = "bigqueryNoDelete"
  title       = "BigQuery Admin No Delete"
  description = "BigQuery Admin role without delete permissions"
  permissions = [
    "bigquery.datasets.create",
    "bigquery.datasets.get",
    "bigquery.datasets.update",
    "bigquery.datasets.getIamPolicy",
    "bigquery.datasets.setIamPolicy",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.jobs.list",
    "bigquery.jobs.update",
    "bigquery.tables.create",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.getIamPolicy",
    "bigquery.tables.list",
    "bigquery.tables.setIamPolicy",
    "bigquery.tables.update",
    "bigquery.tables.updateData"
  ]
}

# Create custom role for Storage without delete permissions
resource "google_project_iam_custom_role" "storage_no_delete" {
  role_id     = "storageNoDelete"
  title       = "Storage Admin No Delete"
  description = "Storage Admin role without delete permissions"
  permissions = [
    "storage.buckets.create",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.list",
    "storage.buckets.setIamPolicy",
    "storage.buckets.update",
    "storage.objects.create",
    "storage.objects.get",
    "storage.objects.getIamPolicy",
    "storage.objects.list",
    "storage.objects.setIamPolicy",
    "storage.objects.update"
  ]
}

# Assign custom BigQuery role to the user
resource "google_project_iam_member" "user_bq_no_delete" {
  project = var.project_id
  role    = google_project_iam_custom_role.bigquery_no_delete.id
  member  = "user:nikhila.nethikunta@gamil.com"
}

# Assign custom Storage role to the user
resource "google_project_iam_member" "user_storage_no_delete" {
  project = var.project_id
  role    = google_project_iam_custom_role.storage_no_delete.id
  member  = "user:nikhila.nethikunta@gamil.com"
}
