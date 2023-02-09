data "aws_organizations_organization" "root" {}

data "aws_kms_alias" "guardduty" {
  provider = aws.security
  name     = var.kms_key_alias
}

data "aws_s3_bucket" "guardduty" {
  provider = aws.security
  bucket   = var.guardduty_bucket
}
