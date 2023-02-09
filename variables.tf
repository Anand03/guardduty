variable "s3_logs_status" {
  type    = string
  default = "true"
}

variable "k8s_audit_logs_status" {
  type    = string
  default = "true"
}

variable "malware_protection_status" {
  type    = string
  default = "true"
}

variable "delegated_admin_acc_id" {
  type    = string
  default = "<account id for delegated admin account>"
}

variable "delegated_admin_acc_email" {
  type    = string
  default = "<email id of delegated admin acc>"
}

variable "guardduty_bucket" {
  type    = string
  default = "<bucket name to store findings>"
}

variable "kms_key_alias" {
  type    = string
  default = "<alias for kms key>"
}
