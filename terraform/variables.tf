variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "your_gcp_project_id"
}

variable "region" {
  description = "The region to deploy resources to ex - singapore"
  type        = string
  default     = "asia-southeast1"
}

variable "bucket_name" {
  description = "The name of the GCS bucket"
  type        = string
  default     = "gcp-example-bucket_name"
}

variable "credentials_file" {
  description = "Path to the service account key file i.e adc file"
  type        = string
  default     = "/path_to_adc_file/my-adc.json"
}
