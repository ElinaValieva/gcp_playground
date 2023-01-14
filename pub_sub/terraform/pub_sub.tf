resource "google_pubsub_topic" "topic" {
  project = var.project
  name    = "functions2-topic"
}