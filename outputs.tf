output "export_arn" {
  description = "ARN of the AWS Data Export."
  value       = aws_bcmdataexports_export.this.arn
}

output "bucket_name" {
  description = "Name of the destination S3 bucket."
  value       = local.bucket_name
}

output "bucket_arn" {
  description = "ARN of the destination S3 bucket."
  value       = local.bucket_arn
}

output "s3_prefix" {
  description = "S3 key prefix used for export delivery."
  value       = var.s3_prefix
}

output "s3_uri" {
  description = "Base S3 URI under which the export is delivered."
  value       = "s3://${local.bucket_name}/${trim(var.s3_prefix, "/")}/${var.name}/"
}

output "bucket_policy_json" {
  description = "Rendered Data Exports bucket policy, or null when policy management is disabled."
  value       = var.create_bucket_policy ? data.aws_iam_policy_document.data_exports[0].json : null
}
