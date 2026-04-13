resource "google_storage_bucket" "configs" {
  name         = var.bucket_name
  location     = var.location
  storage_class = var.storage_class
  labels       = var.bucket_labels

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "configs_binding" {
  for_each = { for idx, binding in var.iam_members : idx => binding }

  bucket = google_storage_bucket.configs.name
  role   = each.value.role
  member = each.value.member
}
