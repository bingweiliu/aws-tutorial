output "bucket_kms_key_arn" {
  value = "${module.bucket_kms_key.kms_key_arn}"
}

output "bucket_kms_key_alias" {
  value = "${module.bucket_kms_key.kms_key_alias}"
}

output "bucket_arn" {
  value = "${module.my-s3-bucket.the_bucekt_arn}"
}

output "bucket_name" {
  value = "${module.my-s3-bucket.the_bucekt_name}"
}

output "external_role_arn" {
  value = "${module.cloudsummit_external_role.external_role_arn}"
}

