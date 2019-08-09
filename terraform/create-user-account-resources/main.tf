# general account settings
variable aws_region {}
variable aws_profile {}
variable environment {}
variable application {}
variable admin_policy_arn {}
variable account_id {
  type = "map"
}

variable admin_arn {
  type = "map"
}

variable admin_group_name {}
variable admin_user_name {}
variable bucket_name {}


# 
variable attach_policy_to_internal_group {}

# 
variable external_account_id {}
variable external_generated_external_id {}
variable external_role_name {}

# setup aws provider
provider "aws" {
  profile = "${var.aws_profile}"
  region  = "us-east-1"
}

# create admin group (for s3)
resource "aws_iam_group" "admin_group" {
  name = "${var.admin_group_name}"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "attach_admin_policy" {
  group      = "${aws_iam_group.admin_group.name}"
  policy_arn = "${var.admin_policy_arn}"
}

resource "aws_iam_user_group_membership" "admin_user_group" {
  user = "${var.admin_user_name}"

  groups = [
    "${aws_iam_group.admin_group.name}"
  ]
}

# create external role

## KMS key for bucket
module "bucket_kms_key" {
  source = "../src/kms-key"
  kms_key_alias = "${var.bucket_name}-key"
  kms_key_description = "kms key for bucket ${var.bucket_name}"
  admin_arn = "${var.admin_arn[var.environment]}"
  account_id = "${var.account_id[var.environment]}"
  application = "${var.application}"
  environment = "${var.environment}"
}

module "bucket_kms_key_policy" {
  source = "../src/kms-key-policy"
  kms_key_arn = "${module.bucket_kms_key.kms_key_arn}"
  policy_name = "allowUseKmsKey"
}

resource "aws_iam_policy_attachment" "allow_bucket_kms_key_attachment" {
    name = "AllowUserKeyPolicyAttachment"
    groups = ["${var.admin_group_name}"]
    roles = [ "${var.external_role_name}" ]
    policy_arn = "${module.bucket_kms_key_policy.kms_key_policy_arn}"
}

module "my-s3-bucket" {
  source = "../src/s3-bucket-enc"
  bucket_name   = "${var.bucket_name}"
  environment = "${var.environment}"
  attach_policy_to_internal_group = "${var.attach_policy_to_internal_group}"
  role_name = "${var.external_role_name}"
  role_read_only = false
  role_read_write = true
  internal_group_name = "${var.admin_group_name}"
}

module "cloudsummit_external_role" {
  source = "../src/external-role"
  external_account_id = "${var.external_account_id}"
  external_generated_external_id = "${var.external_generated_external_id}"
  external_role_name  = "${var.external_role_name}"
}
