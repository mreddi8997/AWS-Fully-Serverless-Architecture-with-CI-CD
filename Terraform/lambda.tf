# Reference your existing artifact bucket
data "aws_s3_bucket" "artifact_bucket" {
  bucket = "artifact-bucket-431445718171-us-east-2-an"
}

resource "aws_lambda_function" "api_lambda" {
  function_name = "serverless_api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x" # Upgraded from deprecated nodejs16.x


  # S3 deployment package location
  s3_bucket = data.aws_s3_bucket.artifact_bucket.id
  s3_key    = "lambda.zip"

  vpc_config {
    subnet_ids         = [aws_subnet.app_private_subnet_1.id, aws_subnet.app_private_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      ENVIRONMENT = "lambda"
      S3_BUCKET   = aws_s3_bucket.s3_bucket.id
      REGION      = "us-east-2"                        # Added missing double quotes
      HOST        = aws_db_instance.mysql-db.address   # Use .address instead of .endpoint to omit port
      DATABASE    = aws_db_instance.mysql-db.db_name   # Fixed attribute (was database_name)
      SECRET_ID   = aws_db_instance.mysql-db.master_user_secret[0].secret_arn
    }
  }

  timeout = 30
}

resource "aws_lambda_permission" "permissions" {
  for_each = {
    "all_permission" : "/*/*"
    # "healthz_permission" : "/ANY/healthz",
    # "create_user_permission" : "/ANY/user",
    # "get_user_permission" : "/ANY/user/*",
    # "update_user_permission" : "/PUT/user/*",
    # "get_product_permission" : "/ANY/product/*",
    # "create_product_permission" : "/ANY/product",
    # "put_product_permission" : "/PUT/product/*",
    # "patch_product_permission" : "/PATCH/product/*",
    # "delete_product_permission" : "/DELETE/product/*",
    # "get_images_permission" : "/ANY/product/*/image",
    # "get_image_permission" : "/ANY/product/*/image/*",
    # "upload_image_permission" : "/POST/product/*/image",
    # "delete_image_permission" : "/DELETE/product/*/image/*"
  }
  statement_id  = each.key
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*${each.value}"
}
