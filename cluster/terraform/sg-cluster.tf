provider "google" {
  project = "solar-virtue-183310"
  region  = "europe-west1"
  version = "~> 1.2"
}

resource "google_container_cluster" "sg-gke" {
  name                     = "sourcegraph-eu1"
  zone                     = "europe-west1-d"
  network                  = "sourcegraph-network"
  subnetwork               = "sourcegraph-eu1"
  node_version             = "1.10.7-gke.1"
  min_master_version       = "1.10.7-gke.1"
  initial_node_count       = 3
  remove_default_node_pool = true

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pods"
    services_secondary_range_name = "k8s-services"
  }

  master_auth {
    username = "admin"
    password = "JCGmQRwu6OX4Plqj6ajAzjDDkeYskp1Y"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  depends_on  = ["google_compute_subnetwork.sg-eu1-subnet"]
}

resource "google_container_node_pool" "sg-gke-n1-8-pool" {
  name               = "sourcegraph-pool"
  zone               = "${google_container_cluster.sg-gke.zone}"
  cluster            = "${google_container_cluster.sg-gke.name}"
  initial_node_count = 3

  version = "1.10.7-gke.1"

  depends_on = ["google_container_cluster.sg-gke"]

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "n1-standard-8"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
    ]

    labels = {
      owner         = "infra"
      owner_subteam = "engineering-velocity"
      role          = "sourcegraph"
    }

    tags = [
      "sourcegraph",
      "intinf-eu1",
    ]
  }
}
