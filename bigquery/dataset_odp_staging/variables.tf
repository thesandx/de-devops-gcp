variable "dataset_id" {
  description = "The dataset ID"
  type        = string
}

variable "description" {
  description = "Dataset description"
  type        = string
}

variable "location" {
  description = "Dataset location"
  type        = string
}

variable "labels" {
  description = "Dataset labels"
  type        = map(string)
}

variable "service_account_email" {
  description = "Email of the service account that will have write access (dataEditor)"
  type        = string
}

variable "analyst_email" {
  description = "Email of the human analyst that will have read-only access (dataViewer)"
  type        = string
}
