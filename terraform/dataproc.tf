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