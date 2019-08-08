output "the_bucekt_arn" {
  value = "${aws_s3_bucket.the_bucket.arn}"
}

output "the_bucekt_name" {
  value = "${aws_s3_bucket.the_bucket.id}"
}