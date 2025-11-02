resource "google_service_account" "ci" {
  account_id   = "tf-ci-sa"
  display_name = "Terraform CI Service Account"
}

resource "google_storage_bucket" "tfstate_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = false
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.bigquery_dataset
  location   = var.region
}
