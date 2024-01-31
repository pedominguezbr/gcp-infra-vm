terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.3.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.21.1"
    }
  }
  backend "gcs" {
    bucket = "miapp_terraform"
    prefix = "staging-testing-jmeter"
  }
}

provider "google" {
  project = var.gcloud_project_id
  region  = var.gcloud_region
  zone    = var.gcloud_zone
}
provider "google-beta" {
  project = var.gcloud_project_id
  region  = var.gcloud_region
  zone    = var.gcloud_zone
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host = "https://${google_container_cluster.primary_worker_ipv6.endpoint}"

  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(google_container_cluster.primary_worker_ipv6.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.primary_worker_ipv6.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.primary_worker_ipv6.master_auth.0.cluster_ca_certificate)

  ignore_annotations = ["cloud.google.com\\/neg-status"]
}
