resource "google_service_account" "cloud_run" {
  project = var.project
  account_id   = "cloud-run"
  display_name = "Cloud Run Invoker Service Account"
  depends_on   = [
    google_project_service.default,
  ]
}

data "google_iam_policy" "run_invoker_policy" {
  binding {
    role    = "roles/run.invoker"
    members = ["serviceAccount:${google_service_account.cloud_run.email}"]
  }
}

resource "google_cloud_run_service_iam_policy" "run_invoker_iam_policy" {
  project  = var.project
  location = google_cloud_run_service.cloud_run.location
  service  = google_cloud_run_service.cloud_run.name

  policy_data = data.google_iam_policy.run_invoker_policy.policy_data
}