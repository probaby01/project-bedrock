resource "aws_s3_bucket" "pb_s3" {
  bucket = "bedrock-assets-1174"

  tags = {
    Name = "bedrock-assets-1174"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.pb_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ===============
# Lambda
# ===============

resource "aws_iam_role" "iam_for_lambda" {
  name = "bedrock-asset-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "bedrock_asset_processor.py"
  output_path = "${path.root}/bedrock_asset_processor.zip"
}

resource "aws_lambda_function" "bedrock_asset_processor" {
  filename      = data.archive_file.lambda.output_path
  function_name = "bedrock-asset-processor"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "bedrock_asset_processor.handler"
  runtime       = "python3.11"

  source_code_hash = data.archive_file.lambda.output_base64sha256
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bedrock_asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.pb_s3.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.pb_s3.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.bedrock_asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}