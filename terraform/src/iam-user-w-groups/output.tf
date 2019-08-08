output "username" {
  value = "${aws_iam_user.user.name}"
}

output "encrypted_password" {
  value = "${aws_iam_user_login_profile.login_profile.encrypted_password}"
}