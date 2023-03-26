terraform {
  source = "..//module"
}

# we can include a default provider for the region where guardduty has to be enabled (in this case we are deploying in us-east-1)
# dst provider should be of the admin account in the region
# one should be specific to the guardduty admin account (security maybe?) (assuming in eu-central-1)
# Change values accordingly

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias = "dst"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::<admin_acc_id>:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias = "security"
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::<admin_acc_id>:role/OrganizationAccountAccessRole"
  }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
# Change values accordingly
remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-remote-state"
    key            = "guardduty/<region>/terraform.tfstate"
    encrypt        = true
    kms_key_id     = "<arn of kms>"
    region         = "eu-central-1"
    dynamodb_table = "main_terraform_lock_table"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
