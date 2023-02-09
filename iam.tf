resource "aws_iam_role" "GuardDutyTerraformLoggingAcctRole" {
  provider = aws.security
  name     = "GuardDutyTerraformOrgRole"

  # Set the Trusted principal to the Management account
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowAssumeRole"
        Principal = {
          "AWS" = "arn:aws:iam::${data.aws_organizations_organization.root.master_account_id}:root"
        }
      }
    ]
  })
}

# IAM definitions for GuardDutyTerraformOrgRole for the logging account
data "aws_iam_policy_document" "logging_acct_pol" {

  statement {
    sid    = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "{arn:aws:s3:::<s3-bucket-name>}"
    ]
  }
  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:ListGrants",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:ListKeys",
      "kms:ListResourceTags",
      "kms:GetKeyRotationStatus",
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion",
      "kms:GenerateDataKey",
      "kms:CreateKey",
      "kms:EnableKeyRotation",
      "kms:CreateAlias",
      "kms:ListAliases",
      "kms:DeleteAlias"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["<admin acc id>"]
    }
  }
  statement {
    sid       = "AllowIamPerms"
    effect    = "Allow"
    actions   = ["iam:GetRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/*guardduty.amazonaws.com/*"]
  }
  statement {
    sid       = "AllowSvcLinkedRolePerms"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/*guardduty.amazonaws.com/*"]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["guardduty.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "gd_terraform_logging_acct_policy" {
  provider = aws.security
  name     = "gd_terraform_logging_acct_policy"
  policy   = data.aws_iam_policy_document.logging_acct_pol.json
}

resource "aws_iam_role_policy_attachment" "attach_gd_terraform_logging_acct_policy" {
  provider   = aws.security
  role       = aws_iam_role.GuardDutyTerraformLoggingAcctRole.name
  policy_arn = aws_iam_policy.gd_terraform_logging_acct_policy.arn
}

resource "aws_iam_role_policy_attachment" "guardduty_admin_role_policy_attachment" {
  provider   = aws.security
  policy_arn = "arn:aws:iam::aws:policy/AmazonGuardDutyFullAccess"
  role       = aws_iam_role.GuardDutyTerraformLoggingAcctRole.name
}
