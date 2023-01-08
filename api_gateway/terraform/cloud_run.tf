resource "google_cloud_run_service" "cloud_run" {
  name     = "hello"
  location = var.region
  project  = var.project

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"

      }
    }
  }

  depends_on = [google_project_service.default]
}

output "cloud_run_secured" {
  value = google_cloud_run_service.cloud_run.status[0].url
}