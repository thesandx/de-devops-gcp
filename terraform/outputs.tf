output "service_account_email" {
  value = google_service_account.ci.email
}
output "bucket_name" {
  value = google_storage_bucket.tfstate_bucket.name
}

output "bucket_url" {
  description = "The URL of the created GCS bucket"
  value       = google_storage_bucket.tfstate_bucket.url
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.dataset.dataset_id
}
