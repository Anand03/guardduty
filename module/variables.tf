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
  default = ""
}

variable "delegated_admin_acc_email" {
  type    = string
  default = ""
}

# assuming bucket is in place
variable "guardduty_bucket" {
  type    = string
  default = ""
}

variable "kms_key_alias" {
  type    = string
  default = ""
}
