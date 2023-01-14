resource "google_service_account" "account" {
  project      = var.project
  account_id   = "function-run"
  display_name = "Cloud Function Invoker Service Account"
}

data "google_iam_policy" "run_invoker_policy" {
  binding {
    role    = "roles/storage.objectViewer"
    members = ["serviceAccount:${google_service_account.account.email}"]
  }
}

resource "google_storage_bucket" "bucket" {
  project                     = var.project
  name                        = "${var.project}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "function/function-source.zip"
}

resource "google_cloudfunctions2_function" "function" {
  project     = var.project
  name        = "function"
  location    = var.region
  description = "a new function"

  build_config {
    runtime               = "nodejs16"
    entry_point           = "PingPongPubSub"
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count               = 3
    min_instance_count               = 1
    available_memory                 = "1Gi"
    timeout_seconds                  = 60
    max_instance_request_concurrency = 80
    available_cpu                    = "2"
    environment_variables            = {
      TOPIC_ID = google_pubsub_topic.topic.id
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.account.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }

  depends_on = [google_pubsub_topic.topic, google_project_service.default]
}
