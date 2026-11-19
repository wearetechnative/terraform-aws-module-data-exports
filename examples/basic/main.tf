provider "aws" {
  region = "us-east-1"
}

module "data_exports" {
  source = "../.."

  name        = "cur-2-0"
  description = "Hourly CUR 2.0 export"

  bucket_name               = "replace-with-a-globally-unique-bucket-name"
  lifecycle_expiration_days = 395

  tags = {
    ManagedBy = "Terraform"
  }
}
