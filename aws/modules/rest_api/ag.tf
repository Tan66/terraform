resource "aws_api_gateway_rest_api" "rest_api" {
  name = "test"
  description = "test"
  endpoint_configuration {
    types            = var.types
    vpc_endpoint_ids = var.types[0] == "PRIVATE" ? var.endpoint_ids : null
  }
}