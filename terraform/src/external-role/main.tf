variable external_account_id {}
variable external_generated_external_id {}
variable external_role_name {}

resource "aws_iam_role" "external_role" {
  name = "${var.external_role_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${var.external_generated_external_id}"
        }
      },
      "Principal": {
        "AWS": "arn:aws:iam::${var.external_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
