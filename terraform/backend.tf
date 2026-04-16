terraform {
  backend "gcs" {
    bucket  = "de-devops-tf-state" # Replace with your actual globally unique bucket name
    prefix  = "terraform/state"
  }

  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
