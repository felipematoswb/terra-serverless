data "archive_file" "lambda-function-data-zip" {
	type             = "zip"
	source_file      = "${path.module}/lambda/index.js"
	output_path      = "${path.module}/lambda/lambda-my-function.zip"
}

resource "aws_lambda_function" "crud_lambda" {
	filename      = data.archive_file.lambda-function-data-zip.output_path
	function_name = "crud_with_lambda"
	role          = aws_iam_role.lambda-role-for-access-dynamo-and-cloudwatch.arn
	handler       = "index.handler"
	source_code_hash 	= data.archive_file.lambda-function-data-zip.output_base64sha256
	runtime 			= "nodejs14.x"

	environment {
		variables = {
			environment = "dev"
		}
	}

	tracing_config {
		mode = "Active"
	}
}