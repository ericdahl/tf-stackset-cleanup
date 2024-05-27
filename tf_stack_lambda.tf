resource "aws_cloudformation_stack" "example" {
  name          = "example-lambda-stack"

  capabilities = ["CAPABILITY_NAMED_IAM"]

  template_body = <<TEMPLATE
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  LambdaExecutionRole:
    Type: 'AWS::IAM::Role'
    Properties:
      RoleName: 'lambda_execution_role'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: 'Allow'
            Principal:
              Service: 'lambda.amazonaws.com'
            Action: 'sts:AssumeRole'
      Policies:
        - PolicyName: 'LambdaExecutionPolicy'
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: 'Allow'
                Action:
                  - 'logs:CreateLogGroup'
                  - 'logs:CreateLogStream'
                  - 'logs:PutLogEvents'
                Resource: 'arn:aws:logs:*:*:*'
              - Effect: 'Allow'
                Action:
                  - 'iam:DeleteRole'
                  - 'iam:DetachRolePolicy'
                  - 'iam:DeletePolicy'
                Resource: '*'

  DeleteIAMResourcesLambda:
    Type: 'AWS::Lambda::Function'
    Properties:
      FunctionName: 'DeleteIAMResourcesLambda'
      Handler: 'index.lambda_handler'
      Runtime: 'python3.9'
      Role: !GetAtt LambdaExecutionRole.Arn
      Code:
        ZipFile: |
          import json
          import boto3

          def lambda_handler(event, context):
              iam = boto3.client('iam')
              try:
                  role_name = "DeleteMe"
                  policy_arn = f"arn:aws:iam::$${AWS::AccountId}:policy/DeleteMe-Policy"

                  # Detach AWS Managed Policy
                  iam.detach_role_policy(
                      RoleName=role_name,
                      PolicyArn='arn:aws:iam::aws:policy/job-function/ViewOnlyAccess'
                  )

                  # Detach Customer Managed Policy
                  iam.detach_role_policy(
                      RoleName=role_name,
                      PolicyArn=policy_arn
                  )

                  # Delete Customer Managed Policy
                  iam.delete_policy(
                      PolicyArn=policy_arn
                  )

                  # Delete Role
                  iam.delete_role(
                      RoleName=role_name
                  )

                  return {
                      'statusCode': 200,
                      'body': json.dumps('Role and Policies deleted successfully!')
                  }
              except Exception as e:
                  return {
                      'statusCode': 500,
                      'body': json.dumps(f"Error: {str(e)}")
                  }

  LambdaTriggerCustomResource:
    Type: 'AWS::CloudFormation::CustomResource'
    Properties:
      ServiceToken: !GetAtt DeleteIAMResourcesLambda.Arn
      accountId: !Ref 'AWS::AccountId'
TEMPLATE
}
