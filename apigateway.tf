resource "aws_api_gateway_rest_api" "rest-api-example" {
    name        = "Simple PetStore"
    description = "This is my API for demonstration purposes"
	depends_on = [
	  	aws_lambda_function.crud_lambda
	]
}

resource "aws_api_gateway_resource" "api-resource-root-pets" {
    parent_id   = aws_api_gateway_rest_api.rest-api-example.root_resource_id
    path_part   = "pets"
    rest_api_id = aws_api_gateway_rest_api.rest-api-example.id
}

resource "aws_api_gateway_resource" "api-resource-pets" {
    parent_id   = aws_api_gateway_resource.api-resource-root-pets.id
    path_part   = "{id}"
    rest_api_id = aws_api_gateway_rest_api.rest-api-example.id
}

resource "aws_api_gateway_method" "method-get-for-root" {
    authorization = "NONE"
    http_method   = "GET"
    resource_id   = aws_api_gateway_resource.api-resource-root-pets.id
    rest_api_id   = aws_api_gateway_rest_api.rest-api-example.id
}

resource "aws_api_gateway_method" "method-put-for-root" {
    authorization = "NONE"
    http_method   = "PUT"
    resource_id   = aws_api_gateway_resource.api-resource-root-pets.id
    rest_api_id   = aws_api_gateway_rest_api.rest-api-example.id
}

resource "aws_api_gateway_method" "method-delete-for-pets-id" {
    authorization = "NONE"
    http_method   = "DELETE"
    resource_id   = aws_api_gateway_resource.api-resource-pets.id
    rest_api_id   = aws_api_gateway_rest_api.rest-api-example.id
}

resource "aws_api_gateway_method" "method-get-for-pets-id" {
    authorization = "NONE"
    http_method   = "GET"
    resource_id   = aws_api_gateway_resource.api-resource-pets.id
    rest_api_id   = aws_api_gateway_rest_api.rest-api-example.id
}

resource "aws_api_gateway_integration" "integration-lambda-pets-get" {
    http_method = aws_api_gateway_method.method-get-for-root.http_method
    resource_id = aws_api_gateway_resource.api-resource-root-pets.id
    rest_api_id = aws_api_gateway_rest_api.rest-api-example.id
    type        = "AWS_PROXY"
    integration_http_method = "POST"
    uri                 = aws_lambda_function.crud_lambda.invoke_arn
    content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "integration-lambda-pets-put" {
    http_method = aws_api_gateway_method.method-put-for-root.http_method
    resource_id = aws_api_gateway_resource.api-resource-root-pets.id
    rest_api_id = aws_api_gateway_rest_api.rest-api-example.id
    type        = "AWS_PROXY"
    integration_http_method = "POST"
    uri                 = aws_lambda_function.crud_lambda.invoke_arn
    content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "integration-lambda-pets-id-delete" {
    http_method = aws_api_gateway_method.method-delete-for-pets-id.http_method
    resource_id = aws_api_gateway_resource.api-resource-pets.id
    rest_api_id = aws_api_gateway_rest_api.rest-api-example.id
    type        = "AWS_PROXY"
    integration_http_method = "POST"
    uri                 = aws_lambda_function.crud_lambda.invoke_arn
    content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "integration-lambda-pets-id-get" {
    http_method = aws_api_gateway_method.method-get-for-pets-id.http_method
    resource_id = aws_api_gateway_resource.api-resource-pets.id
    rest_api_id = aws_api_gateway_rest_api.rest-api-example.id
    type        = "AWS_PROXY"
    integration_http_method = "POST"
    uri                 = aws_lambda_function.crud_lambda.invoke_arn
    content_handling    = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_deployment" "deployment-dev" {
    rest_api_id = aws_api_gateway_rest_api.rest-api-example.id
    description = "Deployment in DEV"

    triggers = {
        redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest-api-example.body))
    }

    lifecycle {
        create_before_destroy = true
    }

	depends_on = [
	  	aws_api_gateway_method.method-put-for-root,
	]
}

resource "aws_api_gateway_stage" "pets-stage-dev" {
    deployment_id = aws_api_gateway_deployment.deployment-dev.id
    rest_api_id   = aws_api_gateway_rest_api.rest-api-example.id
    stage_name    = "dev"
	xray_tracing_enabled = true
	access_log_settings {
		destination_arn = aws_cloudwatch_log_group.apigateway-pets-customlogs.arn
		format = "{ \"requestId\":\"$context.requestId\", \"extendedRequestId\":\"$context.extendedRequestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
	}

	depends_on = [
	  aws_cloudwatch_log_group.apigateway-pets-customlogs
	]
}


resource "aws_api_gateway_account" "apigateway-account-settings-default" {
  	cloudwatch_role_arn = aws_iam_role.apigateway-role-put-logs-into-cloudwatch.arn
}

resource "aws_api_gateway_method_settings" "pet-settings-stage-dev" {
	rest_api_id = aws_api_gateway_rest_api.rest-api-example.id
	stage_name  = aws_api_gateway_stage.pets-stage-dev.stage_name
	method_path = "*/*"

	settings {
		metrics_enabled = true
		logging_level   = "INFO"
		data_trace_enabled = true
		throttling_rate_limit  = 100
	}

	depends_on = [
	  aws_api_gateway_account.apigateway-account-settings-default
	]
}

