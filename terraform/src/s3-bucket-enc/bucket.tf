variable bucket_name {}
variable environment {}

variable attach_policy_to_internal_group {}
variable internal_group_name {}

variable role_name {}
variable role_read_only {}
variable role_read_write {}

# create the bucket
resource "aws_s3_bucket" "the_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags = {
    Name        = "${var.bucket_name}"
    Environment = "${var.environment}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "PutObjPolicy",
    "Statement": [
        {
            "Sid": "DenyIncorrectEncryptionHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.bucket_name}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "aws:kms"
                }
            }
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.bucket_name}/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        }
    ]
}
POLICY

}

# policy document to allow read only access to the bucket
data "aws_iam_policy_document" "s3_read" {
  statement {
    sid = "allowListBucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "${aws_s3_bucket.the_bucket.arn}",
    ]
  }

  statement {
    sid = "allowGetObject"
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.the_bucket.arn}/*",
    ]
  }
}

# policy document to allow read and write access to the bucket
data "aws_iam_policy_document" "s3_read_write" {
  statement {
    sid = "allowListBucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "${aws_s3_bucket.the_bucket.arn}",
    ]
  }

  statement {
    sid = "allowGetObject"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.the_bucket.arn}/*",
    ]
  }
}

# policy document to allow read, write and delete access to the bucket
data "aws_iam_policy_document" "s3_read_write_delete" {
  statement {
    sid = "allowListBucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "${aws_s3_bucket.the_bucket.arn}",
    ]
  }

  statement {
    sid = "allowGetObject"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.the_bucket.arn}/*",
    ]
  }
}

# 
resource "aws_iam_policy" "s3_read" {
  count = "${var.role_read_only ? 1 : 0}"
  name   = "allowBucketReadOnly${aws_s3_bucket.the_bucket.id}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.s3_read.json}"
}

resource "aws_iam_policy_attachment" "s3_read_only_attachment_to_external_role" {
    count = "${var.role_read_only ? 1 : 0}"
    name = "external_read_policy_attachment"
    roles = ["${var.role_name}"]
    policy_arn = "${aws_iam_policy.s3_read[count.index].arn}"
}

resource "aws_iam_policy" "s3_read_write" {
  count = "${var.role_read_write ? 1 : 0}"
  name   = "allowBucketReadWrite${aws_s3_bucket.the_bucket.id}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.s3_read_write.json}"
}

resource "aws_iam_policy_attachment" "s3_read_write_attachment_to_external_role" {
    count = "${var.role_read_write ? 1 : 0}"
    name = "external_read_write_policy_attachment"
    roles = ["${var.role_name}"]
    policy_arn = "${aws_iam_policy.s3_read_write[count.index].arn}"
}

resource "aws_iam_policy" "s3_read_write_delete" {
  count = "${var.attach_policy_to_internal_group ? 1 : 0}" 
  name   = "allowBucketReadWriteDelete${aws_s3_bucket.the_bucket.id}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.s3_read_write_delete.json}"
}

resource "aws_iam_policy_attachment" "s3_policy_attached_to_internal" {
    count = "${var.attach_policy_to_internal_group ? 1 : 0}" 
    name = "s3_allowall_policy_attachment"
    groups = ["${var.internal_group_name}"]
    policy_arn = "${aws_iam_policy.s3_read_write_delete[count.index].arn}"
}

