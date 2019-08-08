variable user_name {}
variable group_names {
  type = "list"
}

# boolean
variable allow_console_access {}
variable add_user_to_group {}

resource "aws_iam_user" "user" {
  name = "${var.user_name}"
}

resource "aws_iam_user_group_membership" "example1" {
  count = "${var.add_user_to_group ? 1 : 0}"
  user = "${aws_iam_user.user.name}"
  groups = [ "${var.group_names}" ]
}

resource "aws_iam_user_login_profile" "login_profile" {
  count = "${var.allow_console_access ? 1 : 0}"
  user    = "${aws_iam_user.user.name}"
  pgp_key = "keybase:bingweiliu"
  password_reset_required = true
}