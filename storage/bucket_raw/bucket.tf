resource "google_storage_bucket" "raw" {
  name         = var.bucket_name
  location     = var.location
  storage_class = var.storage_class
  labels       = var.bucket_labels

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_member" "raw_binding" {
  for_each = { for idx, binding in var.iam_members : idx => binding }

  bucket = google_storage_bucket.raw.name
  role   = each.value.role
  member = each.value.member
}
