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
