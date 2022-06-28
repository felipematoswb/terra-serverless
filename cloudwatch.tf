resource "aws_cloudwatch_log_group" "apigateway-pets-customlogs" {
    name = "/api/pets/customLogs"
    retention_in_days = 7
    tags = {
        Environment = "dev"
        Application = "apiPets"
    }
}