variable kms_key_alias {}
variable kms_key_description {}

variable admin_arn {}
variable account_id {}

variable application {}
variable environment {}

resource "aws_kms_key" "key" {
  description = "${var.kms_key_description}"
  enable_key_rotation = true
  deletion_window_in_days = 7
  tags = {
    Name        = "${var.kms_key_alias}"
    Environment = "${var.environment}"
    Application = "${var.application}"
  }
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "key-consolepolicy-3",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access for Key Administrators",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.admin_arn}"
      },
      "Action": [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}


resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.kms_key_alias}"
  target_key_id = "${aws_kms_key.key.key_id}"
}