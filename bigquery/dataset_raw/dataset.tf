resource "google_bigquery_dataset" "raw" {
  dataset_id    = var.dataset_id
  description   = var.description
  location      = var.location
  labels        = var.labels

  default_table_expiration_ms     = null
  default_partition_expiration_ms = null
}
