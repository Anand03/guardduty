resource "aws_guardduty_detector" "guardduty_detector" {
  provider = aws.security
  enable   = true

  datasources {
    s3_logs {
      enable = var.s3_logs_status
    }
    kubernetes {
      audit_logs {
        enable = var.k8s_audit_logs_status
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.malware_protection_status
        }
      }
    }
  }
}

resource "aws_guardduty_organization_admin_account" "guardduty_admin" {
  depends_on       = [aws_guardduty_detector.guardduty_detector]
  admin_account_id = var.delegated_admin_acc_id
}

resource "aws_guardduty_organization_configuration" "organization_configuration" {
  provider    = aws.security
  depends_on  = [aws_guardduty_organization_admin_account.guardduty_admin]
  auto_enable = true
  detector_id = aws_guardduty_detector.guardduty_detector.id

  datasources {
    s3_logs {
      auto_enable = var.s3_logs_status
    }
    kubernetes {
      audit_logs {
        enable = var.k8s_audit_logs_status
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = var.malware_protection_status
        }
      }
    }
  }
}

locals {
  accounts       = data.aws_organizations_organization.root.accounts.*.id
  account_ids    = [for account_id in local.accounts : account_id if account_id != var.delegated_admin_acc_id]
  emails         = data.aws_organizations_organization.root.accounts.*.email
  account_emails = [for account_email in local.emails : account_email if account_email != var.delegated_admin_acc_email]
}

resource "aws_guardduty_member" "members" {
  provider = aws.security

  depends_on = [aws_guardduty_organization_configuration.organization_configuration]

  count = length(local.account_ids)

  detector_id                = aws_guardduty_detector.guardduty_detector.id
  account_id                 = local.account_ids[count.index]
  email                      = local.account_emails[count.index]
  disable_email_notification = true
  invite                     = true

  lifecycle {
    ignore_changes = [
      email
    ]
  }
}

resource "aws_guardduty_publishing_destination" "pub_dest" {
  provider   = aws.security
  depends_on = [aws_guardduty_organization_admin_account.guardduty_admin]

  detector_id     = aws_guardduty_detector.guardduty_detector.id
  destination_arn = data.aws_s3_bucket.guardduty.arn
  kms_key_arn     = data.aws_kms_alias.guardduty.target_key_arn
}
