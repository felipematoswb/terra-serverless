# role for apigateway logs put into cloudwatch
resource "aws_iam_role" "apigateway-role-put-logs-into-cloudwatch" {
    name = "apigateway-role-put-logs-into-cloudwatch"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
                Service = "apigateway.amazonaws.com"
            }
        },
        ]
    })

    tags = {
        terraform = "true"
    }
}

resource "aws_iam_policy" "apigateway-policy-put-logs-into-cloudwatch" {
	name        = "apigateway-policy-put-logs-into-cloudwatch"
	path        = "/"
	description = "IAM policy for logging from a lambda"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ]
            Effect   = "Allow"
            Resource = "*"
        },
        ]
    })
    tags = {
        terraform = "true"
    }
}

resource "aws_iam_role_policy_attachment" "apigateway-attach-put-logs-into-cloudwatch" {
	role       = aws_iam_role.apigateway-role-put-logs-into-cloudwatch.name
	policy_arn = aws_iam_policy.apigateway-policy-put-logs-into-cloudwatch.arn
}

resource "aws_iam_role" "lambda-role-for-access-dynamo-and-cloudwatch" {
	name = "lambda-role-for-access-dynamo-and-cloudwatch"
	assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        },
        ]
    })
    tags = {
        terraform = "true"
    }
}

resource "aws_iam_policy" "lambda-policy-for-access-dynamo-and-cloudwatch" {
	name        = "lambda-policy-for-access-dynamo-and-cloudwatch"
	path        = "/"
	description = "IAM policy for logging from a lambda"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
            ]
            Effect   = "Allow"
            Resource = [
                "arn:aws:logs:*:*:*",
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets",
                "xray:GetSamplingStatisticSummaries"
            ],
            Resource = [
                "*"
            ]
        },
        {
            Action = [
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
            ]
            Effect   = "Allow"
            Resource = [
                "${aws_dynamodb_table.basic-dynamodb-table.arn}"
            ]
        }
        ]
    })
    tags = {
        terraform = "true"
    }
}

resource "aws_iam_role_policy_attachment" "lambda-attach-for-access-dynamo-and-cloudwatch" {
	role       = aws_iam_role.lambda-role-for-access-dynamo-and-cloudwatch.name
	policy_arn = aws_iam_policy.lambda-policy-for-access-dynamo-and-cloudwatch.arn
}