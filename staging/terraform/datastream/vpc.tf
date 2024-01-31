data "google_compute_network" "vpc" {
  name = "${var.gcloud_project_id}-vpc"
}

resource "google_compute_subnetwork" "vpc_subnet_jmeter" {
  name          = "${var.gcloud_project_id}-vpc-subnet-jmeter"
  ip_cidr_range = var.vpc_subnet_vm_cidr_range
  network       = data.google_compute_network.vpc.id
  region        = var.gcloud_region

  # # Add for suppor IPV6 external.
  # stack_type       = "IPV4_IPV6"
  # ipv6_access_type = "EXTERNAL"
}

resource "google_compute_subnetwork" "vpc_subnet_br" {
  name          = "${var.gcloud_project_id}-vpc-subnet-br"
  ip_cidr_range = var.vpc_subnet_vm_br_cidr_range
  network       = data.google_compute_network.vpc.id
  region        = var.gcloud_region_br
}

resource "google_compute_firewall" "ssh" {
  name          = "allow-ingress-tcp-22-shared-networking"
  network       = data.google_compute_network.vpc.self_link
  project       = var.gcloud_project_id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["allow-ssh"]
}

resource "google_compute_firewall" "icmp" {
  name     = "firewall-icmp"
  network  = data.google_compute_network.vpc.self_link
  project  = var.gcloud_project_id
  priority = 999
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  allow {
    protocol = "sctp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "esp"
  }
  allow {
    protocol = "ah"
  }
  target_tags   = ["allow-icmp"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "lagscope" {
  name          = "allow-ingress-tcp-lagscope"
  network       = data.google_compute_network.vpc.self_link
  project       = var.gcloud_project_id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["25001"]
  }
  allow {
    protocol = "tcp"
    ports    = ["6001"]
  }
  target_tags = ["allow-ssh"]
}
# resource "google_compute_firewall" "allow-db" {
#   name    = "allow-from-${var.cluster_name}-cluster-to-other-project-db"
#   network = "other-network"
#   allow {
#     protocol = "icmp"
#   }
#   allow {
#     protocol = "tcp"
#     ports    = ["5432"]
#   }
#   source_ranges = ["${var.subnet_cidr}", "${var.pod_range}"]
#   target_tags = ["network-tag-name"]
# }
