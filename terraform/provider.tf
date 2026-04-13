terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  # Uses GOOGLE_APPLICATION_CREDENTIALS environment variable when set (GitHub Actions)
  # Falls back to credentials_file variable for local development
  credentials = var.credentials_file != "" ? file(var.credentials_file) : null
  project     = var.project_id
  region      = var.region
}

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
  description = "Path to the service account key file i.e adc file. Can be empty if GOOGLE_APPLICATION_CREDENTIALS is set (e.g., in GitHub Actions)"
  type        = string
  default     = ""  # Empty by default - GitHub Actions will use GOOGLE_APPLICATION_CREDENTIALS env var
}
