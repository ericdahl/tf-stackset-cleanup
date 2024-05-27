#resource "aws_scheduler_schedule" "delete" {
#  schedule_expression = "rate(3 minutes)"
#  flexible_time_window {
#    mode = "OFF"
#  }
#  target {
#    arn      = "arn:aws:scheduler:::aws-sdk:iam:deleteRole"
#    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
#    input = jsonencode({
#      RoleName : "DeleteMe"
#    })
#  }
#}
#
#resource "aws_scheduler_schedule" "delete_policy" {
#  schedule_expression = "rate(3 minutes)"
#  flexible_time_window {
#    mode = "OFF"
#  }
#  target {
#    arn      = "arn:aws:scheduler:::aws-sdk:iam:deletePolicy"
#    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
#    input = jsonencode({
#      PolicyArn: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/DeleteMe-Policy"
#    })
#  }
#}
#
#
#resource "aws_scheduler_schedule" "detach" {
#  schedule_expression = "rate(3 minutes)"
#  flexible_time_window {
#    mode = "OFF"
#  }
#  target {
#    arn      = "arn:aws:scheduler:::aws-sdk:iam:detachRolePolicy"
#    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
#    input = jsonencode({
#      RoleName : "DeleteMe",
#      PolicyArn: "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
#    })
#  }
#}
#
#resource "aws_scheduler_schedule" "detach_customer_managed" {
#  schedule_expression = "rate(3 minutes)"
#  flexible_time_window {
#    mode = "OFF"
#  }
#  target {
#    arn      = "arn:aws:scheduler:::aws-sdk:iam:detachRolePolicy"
#    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
#    input = jsonencode({
#      RoleName : "DeleteMe",
#      PolicyArn: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/DeleteMe-Policy"
#    })
#  }
#}
#
##
#
#data "aws_iam_policy_document" "assume_role_policy" {
#  statement {
#    actions = ["sts:AssumeRole"]
#
#    principals {
#      type        = "Service"
#      identifiers = ["scheduler.amazonaws.com"]
#    }
#
#    effect = "Allow"
#  }
#}
#
#resource "aws_iam_role" "eventbridge_scheduler_role" {
#  name               = "eventbridge_scheduler_role"
#  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
#}
#
#data "aws_iam_policy_document" "delete_role_policy" {
#  statement {
#    actions   = ["iam:DeleteRole"]
#    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DeleteMe"]
#    effect    = "Allow"
#  }
#
#  statement {
#    actions   = ["iam:DetachRolePolicy", "iam:DeletePolicy"]
#    resources = ["*"]
#    effect    = "Allow"
#  }
#
#}
#
#resource "aws_iam_policy" "delete_role_policy" {
#  name        = "DeleteRolePolicy"
#  description = "Policy to allow deleting IAM roles"
#  policy      = data.aws_iam_policy_document.delete_role_policy.json
#}
#
#resource "aws_iam_role_policy_attachment" "attach_delete_role_policy" {
#  role       = aws_iam_role.eventbridge_scheduler_role.name
#  policy_arn = aws_iam_policy.delete_role_policy.arn
#}
