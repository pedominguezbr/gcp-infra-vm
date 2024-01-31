# Google Cloud Settings.
# Defaults to miapp Staging (https://console.cloud.google.com/home/dashboard?project=miapp-staging).
variable "gcloud_project_id" {
  default = "miapp-staging"
}
variable "gcloud_region" {
  default = "southamerica-west1"
}
variable "gcloud_zone" {
  default = "southamerica-west1-c"
}

variable "gcloud_region_br" {
  default = "southamerica-east1"
}
variable "gcloud_zone_br" {
  default = "southamerica-east1-c"
}

variable "gcloud_zone_br_b" {
  default = "southamerica-east1-b"
}
# Network.

variable "vpc_subnet_vm_cidr_range" {
  default = "10.5.0.0/16"
}

variable "vpc_subnet_vm_br_cidr_range" {
  default = "10.6.0.0/16"
}
# Kubernetes.

# Database.
# variable "gcloud_sql_database_private_ip_address" {
#   default = "10.4.0.2" #ipo de la vm proxy db
# }

# variable "gcloud_sql_database" {
#   default = "miapp"
# }
# variable "gcloud_sql_user_name" {
#   default = "dbuser"
# }
# variable "gcloud_sql_user_password" {
#   default = "n5&dPnkaQNNpFG&z"
# }

# Cloud Storage.
# variable "gcs_whitelabels_bucket_name" {}
# variable "gcs_assets_bucket_name" {}
# variable "horizontal_pod_autoscaling" {
#   default = true
#   type    = bool
# }

variable "vm_username" {
  default = "bruno"
}

variable "name_instance" {
  type    = string
  default = "testing-jmeter"
}

variable "client_email" {
  default = "miapp-staging-deployments@miapp-staging.iam.gserviceaccount.com"
}
variable "path_local_file_sa_pk" {
  default = "../../keys/iam-acount-cloudsqlproxy.json"
}

# Network GKE Worker.
variable "vpc_subnet_worker_ip_cidr_range" {
  default = "10.100.0.0/16"
}
variable "vpc_subnet_worker_pods_cidr_range" {
  default = "10.101.0.0/16"
}
variable "vpc_subnet_worker_services_cidr_range" {
  default = "10.102.0.0/16"
}

variable "google_service_account_deployment_email" {
  default = "miapp-staging-deployments@miapp-staging.iam.gserviceaccount.com"
}
