variable kms_key_arn {}
variable policy_name {}

data "aws_iam_policy_document" "allow_use_kms_key_document" {
  statement {
    sid = "AllowUseKey"
    actions = [
      "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
    ]

    resources = [
      "${var.kms_key_arn}"
    ]
  }

  statement {
    sid = "AllowAttachmentPersistentResources"
    actions = [
       "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
    ]

    resources = [
      "${var.kms_key_arn}"
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = [
        "true"
      ]
    }
  }
}

resource "aws_iam_policy" "allow_user_key_policy" {
  name   = "${var.policy_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.allow_use_kms_key_document.json}"
}


