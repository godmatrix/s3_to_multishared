terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# ==================== S3 BUCKET (EXPLICIT NAME) ====================
resource "aws_s3_bucket" "upload_bucket" {
  bucket = "file-router-upload-bucket"
  tags = { 
    Purpose = "File routing by extension - User upload bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.upload_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.upload_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==================== SNS TOPIC FOR NOTIFICATION ====================
resource "aws_sns_topic" "file_routed" {
  name = "file-routed-notification"
}

# ✅ Added your email
resource "aws_sns_topic_subscription" "email_elucas" {
  topic_arn = aws_sns_topic.file_routed.arn
  protocol  = "email"
  endpoint  = "elucas@ocsheriff.gov"
}

# (Optional) Add more emails here the same way
# resource "aws_sns_topic_subscription" "another_email" {
#   topic_arn = aws_sns_topic.file_routed.arn
#   protocol  = "email"
#   endpoint  = "another@ocsheriff.gov"
# }

# ==================== LAMBDA ROLE ====================
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "file-router-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:CopyObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.upload_bucket.arn}/*"]
  }
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.file_routed.arn]
  }
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_policy_attach" {
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# ==================== LAMBDA FUNCTION ====================
resource "aws_lambda_function" "file_router" {
  filename         = "lambda_function.zip"
  function_name    = "file-router-by-extension"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.file_routed.arn
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_router.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

# ==================== S3 EVENT NOTIFICATION ====================
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_router.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

output "upload_bucket_name" {
  value = aws_s3_bucket.upload_bucket.id
}

output "txt_folder" {
  value = "s3://file-router-upload-bucket/shared/txt/"
}

output "csv_folder" {
  value = "s3://file-router-upload-bucket/shared/csv/"
}

output "notification_email" {
  value = "elucas@ocsheriff.gov"
}