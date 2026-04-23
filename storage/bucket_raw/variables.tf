variable "bucket_name" {
  description = "The bucket name"
  type        = string
}

variable "location" {
  description = "Bucket location"
  type        = string
}

variable "storage_class" {
  description = "Storage class"
  type        = string
}

variable "bucket_labels" {
  description = "Bucket labels"
  type        = map(string)
}

variable "iam_members" {
  description = "IAM members to grant roles on this bucket"
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}
