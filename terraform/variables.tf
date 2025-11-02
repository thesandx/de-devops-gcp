variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "de-devops"
}

variable "region" {
  description = "The region to deploy resources to ex - singapore"
  type        = string
  default     = "asia-southeast1"
}

variable "credentials_file" {
  description = "Path to the service account key file i.e adc file"
  type        = string
  default     = "de-devops-adc.json"
}
