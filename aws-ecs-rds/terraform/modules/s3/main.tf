################################################################################
# S3 Bucket
################################################################################

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name = "${var.env}-${var.bucket_name}"
  }
}

################################################################################
# S3 ACL
################################################################################

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

################################################################################
# S3 Web Config
################################################################################

resource "aws_s3_bucket_website_configuration" "static_web" {
  count = var.bucket_type == "web" ? 1 : 0

  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = "index.html"
  }

  # error_document {
  #   key = "error.html"
  # }
}

################################################################################
# S3 CORS configuration
################################################################################

resource "aws_s3_bucket_cors_configuration" "main" {

  count = var.bucket_type == "image" ? 1 : 0

  bucket = aws_s3_bucket.main.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["${var.domain}"]
  }
}

################################################################################
# S3 Public Access Block
################################################################################

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

################################################################################
# S3 Bucket Policy
################################################################################

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.combined.json
}

data "aws_iam_policy_document" "main" {
  for_each = { for i in var.bucket_policies : i.allow_resource_name => i }

  statement {
    sid    = "Allow ${each.value.allow_resource_name}"
    effect = "Allow"
    principals {
      type        = each.value.principal_type
      identifiers = each.value.identifiers
    }
    actions = each.value.bucket_policy_action

    resources = [
      "${aws_s3_bucket.main.arn}/*",
      "${aws_s3_bucket.main.arn}"
    ]
  }
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = [
    for k, v in data.aws_iam_policy_document.main : v.json
  ]
}

################################################################################
# S3 Versioning
################################################################################

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

################################################################################
# S3 Encryption
################################################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

