
resource "aws_cloudformation_stack" "example" {
  name = "example-stack"

  capabilities = ["CAPABILITY_NAMED_IAM"]


  template_body = <<TEMPLATE
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  EventBridgeSchedulerRole:
    Type: 'AWS::IAM::Role'
    Properties:
      RoleName: 'eventbridge_scheduler_role'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: 'Allow'
            Principal:
              Service: 'scheduler.amazonaws.com'
            Action: 'sts:AssumeRole'

  DeleteRolePolicy:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyName: 'DeleteRolePolicy'
      Roles:
        - Ref: 'EventBridgeSchedulerRole'
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: 'Allow'
            Action: 'iam:DeleteRole'
            Resource: !Sub 'arn:aws:iam::$${AWS::AccountId}:role/DeleteMe'
          - Effect: 'Allow'
            Action:
              - 'iam:DetachRolePolicy'
              - 'iam:DeletePolicy'
            Resource: '*'

  SchedulerDeleteRole:
    Type: 'AWS::Scheduler::Schedule'
    Properties:
      ScheduleExpression: 'rate(3 minutes)'
      FlexibleTimeWindow:
        Mode: 'OFF'
      Target:
        Arn: 'arn:aws:scheduler:::aws-sdk:iam:deleteRole'
        RoleArn: !GetAtt 'EventBridgeSchedulerRole.Arn'
        Input: !Sub '{"RoleName": "DeleteMe"}'

  SchedulerDeletePolicy:
    Type: 'AWS::Scheduler::Schedule'
    Properties:
      ScheduleExpression: 'rate(3 minutes)'
      FlexibleTimeWindow:
        Mode: 'OFF'
      Target:
        Arn: 'arn:aws:scheduler:::aws-sdk:iam:deletePolicy'
        RoleArn: !GetAtt 'EventBridgeSchedulerRole.Arn'
        Input: !Sub '{"PolicyArn": "arn:aws:iam::$${AWS::AccountId}:policy/DeleteMe-Policy"}'

  SchedulerDetachRolePolicy:
    Type: 'AWS::Scheduler::Schedule'
    Properties:
      ScheduleExpression: 'rate(3 minutes)'
      FlexibleTimeWindow:
        Mode: 'OFF'
      Target:
        Arn: 'arn:aws:scheduler:::aws-sdk:iam:detachRolePolicy'
        RoleArn: !GetAtt 'EventBridgeSchedulerRole.Arn'
        Input: !Sub '{"RoleName": "DeleteMe", "PolicyArn": "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"}'

  SchedulerDetachCustomerManagedPolicy:
    Type: 'AWS::Scheduler::Schedule'
    Properties:
      ScheduleExpression: 'rate(3 minutes)'
      FlexibleTimeWindow:
        Mode: 'OFF'
      Target:
        Arn: 'arn:aws:scheduler:::aws-sdk:iam:detachRolePolicy'
        RoleArn: !GetAtt 'EventBridgeSchedulerRole.Arn'
        Input: !Sub '{"RoleName": "DeleteMe", "PolicyArn": "arn:aws:iam::$${AWS::AccountId}:policy/DeleteMe-Policy"}'
TEMPLATE
}
