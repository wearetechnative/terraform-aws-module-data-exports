variable "name" {
  description = "Unique name of the data export."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,128}$", var.name))
    error_message = "name must contain 1-128 letters, numbers, hyphens, or underscores."
  }
}

variable "description" {
  description = "Optional description of the data export."
  type        = string
  default     = null
}

variable "table_name" {
  description = "AWS Data Exports table queried by query_statement. Used to generate the default CUR 2.0 table configuration."
  type        = string
  default     = "COST_AND_USAGE_REPORT"
}

variable "query_statement" {
  description = "SQL query used by Data Exports."
  type        = string
  default     = "SELECT * FROM COST_AND_USAGE_REPORT"
}

variable "table_configurations" {
  description = "Complete Data Exports table configuration. Null generates a CUR 2.0 configuration; use an empty map for tables without configuration."
  type        = map(map(string))
  default     = null
}

variable "billing_view_arn" {
  description = "Billing view ARN for CUR 2.0. Null uses the account's primary billing view."
  type        = string
  default     = null
}

variable "time_granularity" {
  description = "CUR 2.0 time granularity."
  type        = string
  default     = "HOURLY"

  validation {
    condition     = contains(["HOURLY", "DAILY", "MONTHLY"], var.time_granularity)
    error_message = "time_granularity must be HOURLY, DAILY, or MONTHLY."
  }
}

variable "include_resources" {
  description = "Include resource IDs in the CUR 2.0 export."
  type        = bool
  default     = true
}

variable "include_manual_discount_compatibility" {
  description = "Use the manual discount format in the CUR 2.0 export."
  type        = bool
  default     = false
}

variable "include_split_cost_allocation_data" {
  description = "Include split cost allocation data in the CUR 2.0 export."
  type        = bool
  default     = false
}

variable "s3_prefix" {
  description = "S3 key prefix under which AWS delivers the export."
  type        = string
  default     = "data-exports"
}

variable "s3_bucket_name" {
  description = "Name of an existing destination bucket. Null creates a bucket."
  type        = string
  default     = null
}

variable "s3_bucket_region" {
  description = "Region of an existing destination bucket. Null uses the provider region."
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "Exact name for a module-created bucket. Null uses bucket_name_prefix."
  type        = string
  default     = null
}

variable "bucket_name_prefix" {
  description = "Name prefix for a module-created bucket when bucket_name is null."
  type        = string
  default     = "aws-data-exports-"
}

variable "create_bucket_policy" {
  description = "Create the required Data Exports bucket policy. Disable when the bucket policy is managed elsewhere."
  type        = bool
  default     = true
}

variable "bucket_policy_source_documents" {
  description = "Existing IAM policy documents merged into the managed bucket policy."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN for a module-created bucket. Null uses SSE-S3. The key policy must allow S3 use by the account."
  type        = string
  default     = null
}

variable "bucket_force_destroy" {
  description = "Allow destruction of a non-empty module-created bucket."
  type        = bool
  default     = false
}

variable "bucket_versioning_enabled" {
  description = "Enable versioning on a module-created bucket."
  type        = bool
  default     = false
}

variable "lifecycle_expiration_days" {
  description = "Expire export objects after this many days. Null disables the lifecycle rule."
  type        = number
  default     = null

  validation {
    condition     = var.lifecycle_expiration_days == null || var.lifecycle_expiration_days > 0
    error_message = "lifecycle_expiration_days must be null or greater than zero."
  }
}

variable "format" {
  description = "Export file format: PARQUET or TEXT_OR_CSV."
  type        = string
  default     = "PARQUET"

  validation {
    condition     = contains(["PARQUET", "TEXT_OR_CSV"], var.format)
    error_message = "format must be PARQUET or TEXT_OR_CSV."
  }
}

variable "compression" {
  description = "Export compression: PARQUET or GZIP. Must match format."
  type        = string
  default     = "PARQUET"

  validation {
    condition     = contains(["PARQUET", "GZIP"], var.compression)
    error_message = "compression must be PARQUET or GZIP."
  }
}

variable "overwrite" {
  description = "Whether AWS overwrites prior deliveries or creates new versions."
  type        = string
  default     = "OVERWRITE_REPORT"

  validation {
    condition     = contains(["OVERWRITE_REPORT", "CREATE_NEW_REPORT"], var.overwrite)
    error_message = "overwrite must be OVERWRITE_REPORT or CREATE_NEW_REPORT."
  }
}

variable "tags" {
  description = "Tags applied to the export and module-created bucket."
  type        = map(string)
  default     = {}
}
