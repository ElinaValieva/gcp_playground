locals {
  services = [
    "run.googleapis.com",
    "apigateway.googleapis.com"
  ]
}

resource "google_project_service" "default" {
  for_each                   = toset(local.services)
  project                    = var.project
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = false

  depends_on = [var.project]
}