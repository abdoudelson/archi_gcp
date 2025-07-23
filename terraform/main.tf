provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "raw" {
  name          = var.bucket_raw
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket" "staging" {
  name          = var.bucket_staging
  location      = var.region
  force_destroy = true
}

resource "google_bigquery_dataset" "crypto" {
  dataset_id = "crypto"
  location   = var.region
}

resource "google_dataproc_cluster" "dataproc" {
  name   = "crypto-dataproc"
  region = var.region

  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-4"
    }
    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-4"
    }
    software_config {
      image_version = "2.0-debian10"
    }
  }
}

resource "google_composer_environment" "composer" {
  name   = "crypto-composer"
  region = var.composer_location

  config {
    node_count = 3
    software_config {
      image_version = "composer-2.0.29-airflow-2.3.3"
      pypi_packages = {
        "google-cloud-storage" = "2.5.0"
        "requests"             = "2.28.1"
        "dbt-bigquery"         = "1.4.6"
      }
      airflow_config_overrides = {
        "core.dag_concurrency" = "10"
      }
    }
  }
}

resource "google_compute_instance" "nexus" {
  name         = var.nexus_instance_name
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"
      size  = 30
    }
  }

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    docker run -d -p 8081:8081 --name nexus sonatype/nexus3
  EOT
}
