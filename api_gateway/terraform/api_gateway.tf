locals {
  api_config_id_prefix     = "api"
  api_gateway_container_id = "api-gw"
  gateway_id               = "gw"
}

resource "google_api_gateway_api" "api_gw" {
  project      = var.project
  provider     = google-beta
  api_id       = local.api_gateway_container_id
  display_name = "The API Gateway"
  depends_on   = [google_project_service.default]
}

resource "google_api_gateway_api_config" "api_cfg" {
  project              = var.project
  provider             = google-beta
  api                  = google_api_gateway_api.api_gw.api_id
  api_config_id_prefix = local.api_config_id_prefix
  display_name         = "The Config"

  openapi_documents {
    document {
      path     = "spec.yaml"
      contents = base64encode(<<-EOF
      swagger: '2.0'
      info:
        title: api-gateway
        description: API Gateway
        version: 1.0.0
      schemes:
        - https
      produces:
        - application/json
      paths:
        /v1/hello:
          get:
            summary: Hi Service
            operationId: hello-v1
            x-google-backend:
              address: ${google_cloud_run_service.cloud_run.status[0].url}
            responses:
              '200':
                description: OK

    EOF
      )
    }
  }

  depends_on = [google_cloud_run_service.cloud_run]
}

resource "google_api_gateway_gateway" "gw" {
  project = var.project
  provider = google-beta
  region   = var.region

  api_config = google_api_gateway_api_config.api_cfg.id

  gateway_id   = local.gateway_id
  display_name = "The Gateway"

  depends_on = [google_api_gateway_api_config.api_cfg]
}

output "gateway_url" {
  value = "https://${google_api_gateway_gateway.gw.default_hostname}"
}