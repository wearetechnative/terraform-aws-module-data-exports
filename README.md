[![](we-are-technative.png)](https://www.technative.nl)

# Terraform AWS [Data Exports] ![](https://img.shields.io/github/actions/workflow/status/wearetechnative/terraform-aws-module-data-exports/lint.yaml?branch=main&style=plastic&label=lint) ![](https://img.shields.io/github/actions/workflow/status/wearetechnative/terraform-aws-module-data-exports/security-scan.yaml?branch=main&style=plastic&label=security)

This module implements AWS Billing and Cost Management Data Exports, including
an S3 destination bucket. It uses `aws_bcmdataexports_export` and defaults to a
CUR 2.0 export in Parquet format.

The module can create a secure S3 bucket or deliver to an existing bucket. It
also manages the bucket policy required by the AWS Data Exports service.

## How does it work

AWS Data Exports is managed in `us-east-1`. Configure an AWS provider for that
region and pass it to the module. For organization-wide CUR 2.0 data, deploy the
module in the AWS Organizations management account.

The default configuration:

- exports all columns from `COST_AND_USAGE_REPORT`;
- uses hourly granularity and includes resource IDs;
- writes Parquet files;
- overwrites the previous refresh for each billing period; and
- creates an encrypted, private S3 bucket with ACLs disabled.

AWS can take up to 24 hours to deliver the first export.

## First use

Install the repository guardrails after cloning the module:

```shell
pre-commit install
```

Run all checks before opening a pull request:

```shell
pre-commit run --all-files
```

The pre-commit hooks format Terraform, check YAML and whitespace, detect AWS
credentials, and regenerate the Terraform documentation below.

## Usage

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "data_exports" {
  source = "git@github.com:wearetechnative/terraform-aws-module-data-exports.git?ref=v0.0.1"

  providers = {
    aws = aws.us_east_1
  }

  name        = "cur-2-0"
  bucket_name = "example-aws-data-exports"

  lifecycle_expiration_days = 395

  tags = {
    ManagedBy = "Terraform"
  }
}
```

### Existing S3 bucket

Set `s3_bucket_name` when the destination bucket already exists. The module
manages the complete bucket policy by default. Use
`bucket_policy_source_documents` to merge existing statements into that policy,
or set `create_bucket_policy = false` when another Terraform configuration
manages it.

```hcl
module "data_exports" {
  source = "git@github.com:wearetechnative/terraform-aws-module-data-exports.git?ref=v0.0.1"

  providers = {
    aws = aws.us_east_1
  }

  name             = "cur-2-0"
  s3_bucket_name   = "existing-aws-data-exports"
  s3_bucket_region = "eu-west-1"
}
```

Only one `aws_s3_bucket_policy` resource should manage a bucket because
applying a bucket policy replaces the complete existing policy.

### Custom data export

Use `query_statement` and `table_configurations` for another Data Exports
table or a filtered export. Set `table_configurations = {}` for a table that
does not require configuration.

```hcl
module "focus_export" {
  source = "git@github.com:wearetechnative/terraform-aws-module-data-exports.git?ref=v0.0.1"

  providers = {
    aws = aws.us_east_1
  }

  name                 = "focus-export"
  table_name           = "FOCUS_1_0_AWS_COLUMNS"
  query_statement      = "SELECT * FROM FOCUS_1_0_AWS_COLUMNS"
  table_configurations = {}
  bucket_name          = "example-aws-focus-export"
}
```

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_bcmdataexports_export.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bcmdataexports_export) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.data_exports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_view_arn"></a> [billing\_view\_arn](#input\_billing\_view\_arn) | Billing view ARN for CUR 2.0. Null uses the account's primary billing view. | `string` | `null` | no |
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy) | Allow destruction of a non-empty module-created bucket. | `bool` | `false` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Exact name for a module-created bucket. Null uses bucket_name_prefix. | `string` | `null` | no |
| <a name="input_bucket_name_prefix"></a> [bucket\_name\_prefix](#input\_bucket\_name\_prefix) | Name prefix for a module-created bucket when bucket_name is null. | `string` | `"aws-data-exports-"` | no |
| <a name="input_bucket_policy_source_documents"></a> [bucket\_policy\_source\_documents](#input\_bucket\_policy\_source\_documents) | Existing IAM policy documents merged into the managed bucket policy. | `list(string)` | `[]` | no |
| <a name="input_bucket_versioning_enabled"></a> [bucket\_versioning\_enabled](#input\_bucket\_versioning\_enabled) | Enable versioning on a module-created bucket. | `bool` | `false` | no |
| <a name="input_compression"></a> [compression](#input\_compression) | Export compression: PARQUET or GZIP. Must match format. | `string` | `"PARQUET"` | no |
| <a name="input_create_bucket_policy"></a> [create\_bucket\_policy](#input\_create\_bucket\_policy) | Create the required Data Exports bucket policy. Disable when the bucket policy is managed elsewhere. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Optional description of the data export. | `string` | `null` | no |
| <a name="input_format"></a> [format](#input\_format) | Export file format: PARQUET or TEXT_OR_CSV. | `string` | `"PARQUET"` | no |
| <a name="input_include_manual_discount_compatibility"></a> [include\_manual\_discount\_compatibility](#input\_include\_manual\_discount\_compatibility) | Use the manual discount format in the CUR 2.0 export. | `bool` | `false` | no |
| <a name="input_include_resources"></a> [include\_resources](#input\_include\_resources) | Include resource IDs in the CUR 2.0 export. | `bool` | `true` | no |
| <a name="input_include_split_cost_allocation_data"></a> [include\_split\_cost\_allocation\_data](#input\_include\_split\_cost\_allocation\_data) | Include split cost allocation data in the CUR 2.0 export. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for a module-created bucket. Null uses SSE-S3. | `string` | `null` | no |
| <a name="input_lifecycle_expiration_days"></a> [lifecycle\_expiration\_days](#input\_lifecycle\_expiration\_days) | Expire export objects after this many days. Null disables the lifecycle rule. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name of the data export. | `string` | n/a | yes |
| <a name="input_overwrite"></a> [overwrite](#input\_overwrite) | Whether AWS overwrites prior deliveries or creates new versions. | `string` | `"OVERWRITE_REPORT"` | no |
| <a name="input_query_statement"></a> [query\_statement](#input\_query\_statement) | SQL query used by Data Exports. | `string` | `"SELECT * FROM COST_AND_USAGE_REPORT"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of an existing destination bucket. Null creates a bucket. | `string` | `null` | no |
| <a name="input_s3_bucket_region"></a> [s3\_bucket\_region](#input\_s3\_bucket\_region) | Region of an existing destination bucket. Null uses the provider region. | `string` | `null` | no |
| <a name="input_s3_prefix"></a> [s3\_prefix](#input\_s3\_prefix) | S3 key prefix under which AWS delivers the export. | `string` | `"data-exports"` | no |
| <a name="input_table_configurations"></a> [table\_configurations](#input\_table\_configurations) | Complete Data Exports table configuration. Null generates a CUR 2.0 configuration. | `map(map(string))` | `null` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | AWS Data Exports table queried by query_statement. | `string` | `"COST_AND_USAGE_REPORT"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the export and module-created bucket. | `map(string)` | `{}` | no |
| <a name="input_time_granularity"></a> [time\_granularity](#input\_time\_granularity) | CUR 2.0 time granularity. | `string` | `"HOURLY"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the destination S3 bucket. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the destination S3 bucket. |
| <a name="output_bucket_policy_json"></a> [bucket\_policy\_json](#output\_bucket\_policy\_json) | Rendered Data Exports bucket policy, or null when policy management is disabled. |
| <a name="output_export_arn"></a> [export\_arn](#output\_export\_arn) | ARN of the AWS Data Export. |
| <a name="output_s3_prefix"></a> [s3\_prefix](#output\_s3\_prefix) | S3 key prefix used for export delivery. |
| <a name="output_s3_uri"></a> [s3\_uri](#output\_s3\_uri) | Base S3 URI under which the export is delivered. |
<!-- END_TF_DOCS -->
