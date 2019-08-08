output "kms_key_arn" {
	value = "${aws_kms_key.key.arn}"
}

output "kms_key_alias" {
	value = "${aws_kms_alias.key_alias.arn}"
}