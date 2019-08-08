output "kms_key_policy_arn" {
  value = "${aws_iam_policy.allow_user_key_policy.arn}"
}

