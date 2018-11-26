resource "google_compute_target_pool" "sg-frontend-proxy" {
  name = "keycloak-proxy"

  instances = [
    "europe-west1-d/sourcegraph-keycloak",
  ]
  depends_on = [
    "google_container_cluster.sg-gke",
    "google_compute_network.sg-network"
    ]
}

resource "google_compute_address" "sg-ext-ip" {
  name         = "sourcegraph-ext-ip"
  address_type = "EXTERNAL"
  region       = "europe-west1"
  depends_on  = ["google_compute_network.sg-network"]
}

resource "google_compute_forwarding_rule" "sg-frontend-lb" {
  name       = "sg-frontend-lb"
  target     = "${google_compute_target_pool.sg-frontend-proxy.self_link}"
  port_range = "443"
  ip_address = "regions/europe-west1/addresses/sourcegraph-ext-ip"

  load_balancing_scheme = "EXTERNAL"
  region                = "europe-west1"
  depends_on            = ["google_compute_address.sg-ext-ip"]
}

resource "google_compute_network" "sg-network" {
  name                    = "sourcegraph-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "sg-eu1-subnet" {
  name          = "sourcegraph-eu1"
  ip_cidr_range = "10.50.0.0/20"
  network       = "${google_compute_network.sg-network.name}"

  region = "europe-west1"

  secondary_ip_range {
    range_name    = "k8s-pods"
    ip_cidr_range = "10.50.16.0/20"
  }

  secondary_ip_range {
    range_name    = "k8s-services"
    ip_cidr_range = "10.50.32.0/20"
  }

  depends_on  = ["google_compute_network.sg-network"]
}

resource "google_compute_global_address" "default" {
  name = "sg-ext-ip"
  address_type = "EXTERNAL"
}


resource "google_compute_firewall" "fw-pod-comms" {
  name      = "sourcegraph-eu1-allow-pods-to-communicate"
  network   = "${google_compute_network.sg-network.name}"
  direction = "INGRESS"

  allow {
    protocol = "all"
  }

  source_tags = ["sourcegraph-net-eu1"]
  target_tags = ["sourcegraph-net-eu1"]
  priority    = 1000
  depends_on  = ["google_compute_network.sg-network"]
}

// TODO: Need to work out some details here still
resource "google_compute_firewall" "fw-ingress" {
  name      = "sourcegraph-eu1-ingress-to-proxy"
  network   = "${google_compute_network.sg-network.name}"
  direction = "INGRESS"

  allow {
    protocol = "TCP"
    ports    = ["443"]
  }

  target_tags = ["sourcegraph-keycloak"]
  priority    = 1000
  depends_on  = ["google_compute_network.sg-network"]
}
