variable attach_policy_to_internal_group {}
variable attach_policy_to_role {}
variable internal_group_name {}

variable policy_arn {}
variable role_name {}

resource "aws_iam_policy_attachment" "attach_policy" {
  count = "${var.attach_policy_to_role ? 1 : 0}"
    name = "policy_attachment"
    roles = ["${var.role_name}"]
    policy_arn = "${var.policy_arn}"
}

resource "aws_iam_policy_attachment" "iam_policy_attached_to_internal" {
    count = "${var.attach_policy_to_internal_group ? 1 : 0}" 
    name = "policy_attachment_internal"
    groups = ["${var.internal_group_name}"]
    policy_arn = "${var.policy_arn}"
}
