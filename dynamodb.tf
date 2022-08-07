resource "aws_dynamodb_table" "basic-dynamodb-table" {
	name           = "pets"
	billing_mode   = "PAY_PER_REQUEST"
	hash_key       = "id"
	
	attribute {
			name = "id"
			type = "S"
	}

	tags = {
			Name        = "dynamodb-table-1"
			Environment = "development"
	}
}

resource "aws_dynamodb_contributor_insights" "dynanodb-insights" {
  	table_name = aws_dynamodb_table.basic-dynamodb-table.name
}