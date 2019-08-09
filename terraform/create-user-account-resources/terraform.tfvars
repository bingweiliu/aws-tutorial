aws_region = "us-east-1"
aws_profile = "default"
environment = "dev"

account_id = {
  dev = "<your aws account number>"
}

admin_arn = {
  dev = "arn:aws:iam::<your aws account number>:user/<admin user name>"
}

admin_group_name = "admins"
admin_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
admin_user_name = "<admin user name>"

attach_policy_to_internal_group = true
bucket_name = "cloudsummit-bucket-<your aws account number>"
application = "cloudsummit"

# external role
external_account_id = "743355281737"
external_generated_external_id = "be740d03293890c9"
external_role_name = "cloud-summit-ext-role"
