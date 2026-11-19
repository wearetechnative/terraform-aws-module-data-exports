resource "aws_bcmdataexports_export" "this" {
  export {
    name        = var.name
    description = var.description

    data_query {
      query_statement      = var.query_statement
      table_configurations = local.table_configurations
    }

    destination_configurations {
      s3_destination {
        s3_bucket = local.bucket_name
        s3_prefix = var.s3_prefix
        s3_region = local.bucket_region

        s3_output_configurations {
          overwrite   = var.overwrite
          format      = var.format
          compression = var.compression
          output_type = "CUSTOM"
        }
      }
    }

    refresh_cadence {
      frequency = "SYNCHRONOUS"
    }
  }

  tags = var.tags

  depends_on = [aws_s3_bucket_policy.this]

  lifecycle {
    precondition {
      condition     = data.aws_region.current.region == "us-east-1"
      error_message = "AWS BCM Data Exports must be managed with an AWS provider configured for us-east-1."
    }

    precondition {
      condition     = (var.format == "PARQUET" && var.compression == "PARQUET") || (var.format == "TEXT_OR_CSV" && var.compression == "GZIP")
      error_message = "PARQUET format requires PARQUET compression; TEXT_OR_CSV format requires GZIP compression."
    }
  }
}
