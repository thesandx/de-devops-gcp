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
