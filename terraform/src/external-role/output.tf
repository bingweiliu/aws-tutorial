output "external_role_arn" {
  value = "${aws_iam_role.external_role.arn}"
}

output "external_role_name" {
  value = "${aws_iam_role.external_role.name}"
}