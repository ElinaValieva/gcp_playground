# API Gateway usage for serverless

![arch](gateway_api.png)

## Usage
- Allows to decouple your frontend from the backend, it can break the frontend requests into several services.
- It can help you to move your monolith backend into a microservices architecture.
- Centralize Authentication access for your APIs
- API monitoring, metrics, quotas, and analytics
- Centralize and manage API versioning

## Terraform example
Example with hello serverless Cloud Run and API Gateway. Cloud Run is secured via IAM when API Gateway is open to the public internet. 

**Note:** app must support Open Api (specification could be generated automatically via swagger)
