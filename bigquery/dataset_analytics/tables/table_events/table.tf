locals {
  schema = jsondecode(file("${path.module}/schema.json"))
}

resource "google_bigquery_table" "events" {
  project    = "de-devops"
  dataset_id = var.dataset_id
  table_id   = local.schema.table_name

  time_partitioning {
    type = local.schema.partitioning.type
    field = local.schema.partitioning.field
  }

  clustering = local.schema.clustering

  schema = jsonencode(local.schema.schema)
}
