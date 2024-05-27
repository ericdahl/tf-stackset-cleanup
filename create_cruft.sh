#!/bin/bash

# Define variables
ROLE_NAME="DeleteMe"
POLICY_NAME="DeleteMe-Policy"
ASSUME_POLICY_DOCUMENT='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'
POLICY_DOCUMENT='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}'

# Create the IAM Role
echo "Creating IAM Role $ROLE_NAME..."
aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document "$ASSUME_POLICY_DOCUMENT"

# Create the IAM Policy
echo "Creating IAM Policy $POLICY_NAME..."
POLICY_ARN=$(aws iam create-policy --policy-name $POLICY_NAME --policy-document "$POLICY_DOCUMENT" --query 'Policy.Arn' --output text)

# Attach the policy to the role
echo "Attaching policy $POLICY_NAME to role $ROLE_NAME..."
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY_ARN

# Attach the ViewOnlyAccess policy to the role
echo "Attaching ViewOnlyAccess policy to role $ROLE_NAME..."
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/job-function/ViewOnlyAccess

echo "Script execution completed."
