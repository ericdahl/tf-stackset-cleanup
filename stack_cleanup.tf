locals {
  current_time       = timestamp()
  current_time_epoch = timeadd(timestamp(), 0)
  future_time        = timeadd(local.current_time_epoch, "180s")
  formatted          = formatdate("YYYY-MM-DD'T'hh:MM:ss", local.future_time)
}


resource "aws_scheduler_schedule" "delete" {
  schedule_expression = "at(2024-05-26T07:00:00)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:iam:deleteRole"
    role_arn = aws_iam_role.eventbridge_scheduler_role.arn
    input = jsonencode({
      RoleName : "DeleteMe"
    })
  }
}

#
#
#resource "aws_cloudformation_stack" "cleanup" {
#  name = "cleanup"
#
#  template_body = <<EOF
#Resources:
#  Schedule:
#    Type: AWS::Scheduler::Schedule
#    Properties:
#      FlexibleTimeWindow:
#        MaximumWindowInMinutes: 3
#        Mode: OFF
#      ScheduleExpression: "at(2024-05-27T12:00:00)"
#      Target:
#        Arn: "arn:aws:scheduler:::aws-sdk:iam:deleteRole"
#        RoleArn: ${aws_iam_role.eventbridge_scheduler_role.arn}
#        Input: "{\"RoleName\" = \"DeleteMe\" }"
#EOF
#
#
#}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "eventbridge_scheduler_role" {
  name               = "eventbridge_scheduler_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "delete_role_policy" {
  statement {
    actions   = ["iam:DeleteRole"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "delete_role_policy" {
  name        = "DeleteRolePolicy"
  description = "Policy to allow deleting IAM roles"
  policy      = data.aws_iam_policy_document.delete_role_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_delete_role_policy" {
  role       = aws_iam_role.eventbridge_scheduler_role.name
  policy_arn = aws_iam_policy.delete_role_policy.arn
}
