provider "google" {
  # project = "vm-normal"  # Replace with your GCP project ID
  project = "proof-concept-452415"
  region  = "asia-southeast1"
}

resource "google_compute_instance" "vm_instance" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "asia-southeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # This block provides a public IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y nginx
    sudo systemctl start nginx
  EOT

  tags = ["web-server"]
}

resource "google_compute_firewall" "allow_web_traffic" {
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
