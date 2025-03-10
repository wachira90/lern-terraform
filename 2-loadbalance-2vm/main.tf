provider "google" {
  project = "my-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
}

# Create an instance template for VMs
resource "google_compute_instance_template" "instance_template" {
  name         = "web-instance-template"
  machine_type = "e2-medium"

  disk {
    boot = true
    auto_delete = true
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}  # Public IP address
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y nginx
    echo "Hello from $(hostname)" | sudo tee /var/www/html/index.html
    sudo systemctl start nginx
  EOT

  tags = ["web-server"]
}

# Create a managed instance group
resource "google_compute_instance_group_manager" "instance_group" {
  name               = "web-instance-group"
  base_instance_name = "web-server"
  zone               = "us-central1-a"
  target_size        = 2  # Number of instances

  version {
    instance_template = google_compute_instance_template.instance_template.id
  }

# HTTP backend service
  named_port {
    name = "http"
    port = 80
  }
}

# Create a firewall rule to allow traffic on ports 80 and 8080
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  # Firewall Rule: Opens ports 80 and 8080
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Create a health check for the Load Balancer
resource "google_compute_health_check" "http_health_check" {
  name                = "http-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

# Health Check: Ensures the VMs are healthy before routing traffic
  http_health_check {
    port = 80
  }
}

# Create a backend service for the Load Balancer
resource "google_compute_backend_service" "web_backend" {
  name          = "web-backend"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.http_health_check.id]

  backend {
    group = google_compute_instance_group_manager.instance_group.instance_group
  }
}

# Create a URL map for the Load Balancer
resource "google_compute_url_map" "web_map" {
  name            = "web-map"
  default_service = google_compute_backend_service.web_backend.id
}

# Create a target HTTP proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.web_map.id
}

# Create a global forwarding rule
resource "google_compute_global_forwarding_rule" "http_forwarding" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
}
