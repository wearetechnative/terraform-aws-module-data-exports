resource "aws_s3_bucket" "this" {
  count = local.create_bucket ? 1 : 0

  bucket        = var.bucket_name
  bucket_prefix = var.bucket_name == null ? var.bucket_name_prefix : null
  force_destroy = var.bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = local.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = local.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = local.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    bucket_key_enabled = var.kms_key_arn != null

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count = local.create_bucket && var.bucket_versioning_enabled ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = local.create_bucket && var.lifecycle_expiration_days != null ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    id     = "expire-data-exports"
    status = "Enabled"

    filter {
      prefix = var.s3_prefix
    }

    expiration {
      days = var.lifecycle_expiration_days
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.bucket_versioning_enabled ? [1] : []
      content {
        noncurrent_days = var.lifecycle_expiration_days
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.create_bucket_policy ? 1 : 0

  bucket = local.bucket_name
  policy = data.aws_iam_policy_document.data_exports[0].json

  depends_on = [aws_s3_bucket_public_access_block.this]
}
