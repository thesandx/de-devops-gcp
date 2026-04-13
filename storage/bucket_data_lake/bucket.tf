resource "google_storage_bucket" "data_lake" {
  name         = var.bucket_name
  location     = var.location
  storage_class = var.storage_class
  labels       = var.bucket_labels

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "data_lake_binding" {
  for_each = { for idx, binding in var.iam_members : idx => binding }

  bucket = google_storage_bucket.data_lake.name
  role   = each.value.role
  member = each.value.member
}
