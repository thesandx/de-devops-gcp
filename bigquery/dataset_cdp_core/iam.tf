# Dataset-level IAM for cdp_core dataset
# Service account gets write access (dataEditor), human analyst gets read-only (dataViewer)

resource "google_bigquery_dataset_iam_member" "data_pipeline_editor" {
  dataset_id = google_bigquery_dataset.cdp_core.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${var.service_account_email}"
}

resource "google_bigquery_dataset_iam_member" "analyst_viewer" {
  dataset_id = google_bigquery_dataset.cdp_core.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "user:${var.analyst_email}"
}
