//Provider for delegated admin account
provider "aws" {
  alias = "security"
  assume_role {
    role_arn = "arn:aws:iam::${var.delegated_admin_acc_id}:role/OrganizationAccountAccessRole"
  }
  region = "eu-central-1"
}
