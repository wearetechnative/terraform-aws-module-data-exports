data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "data_exports" {
  count = var.create_bucket_policy ? 1 : 0

  source_policy_documents = var.bucket_policy_source_documents

  statement {
    sid     = "EnableAWSDataExportsToWriteToS3"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${local.bucket_arn}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["bcm-data-exports.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:bcm-data-exports:us-east-1:${data.aws_caller_identity.current.account_id}:export/*",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
