locals {
  create_bucket = var.s3_bucket_name == null

  bucket_name   = local.create_bucket ? aws_s3_bucket.this[0].id : var.s3_bucket_name
  bucket_arn    = local.create_bucket ? aws_s3_bucket.this[0].arn : "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}"
  bucket_region = local.create_bucket ? data.aws_region.current.region : coalesce(var.s3_bucket_region, data.aws_region.current.region)

  default_table_configurations = var.table_name == "COST_AND_USAGE_REPORT" ? {
    COST_AND_USAGE_REPORT = {
      BILLING_VIEW_ARN                      = coalesce(var.billing_view_arn, "arn:${data.aws_partition.current.partition}:billing::${data.aws_caller_identity.current.account_id}:billingview/primary")
      TIME_GRANULARITY                      = var.time_granularity
      INCLUDE_RESOURCES                     = upper(tostring(var.include_resources))
      INCLUDE_MANUAL_DISCOUNT_COMPATIBILITY = upper(tostring(var.include_manual_discount_compatibility))
      INCLUDE_SPLIT_COST_ALLOCATION_DATA    = upper(tostring(var.include_split_cost_allocation_data))
    }
  } : {}

  table_configurations = var.table_configurations == null ? local.default_table_configurations : var.table_configurations
}
