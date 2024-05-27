#!/bin/sh

# Check if role DeleteMe exists
role_name="DeleteMe"
policy_name="DeleteMe-Policy"

echo "Checking if role $role_name exists..."
role_exists=$(aws iam get-role --role-name "$role_name" 2>&1)

if echo "$role_exists" | grep -q "NoSuchEntity"; then
    echo "Role $role_name does not exist."
else
    echo "Role $role_name exists."

    # Check if policy DeleteMe-Policy exists
    echo "Checking if policy $policy_name exists..."
    policy_exists=$(aws iam get-policy --policy-arn "arn:aws:iam::aws:policy/$policy_name" 2>&1)

    if echo "$policy_exists" | grep -q "NoSuchEntity"; then
        echo "Policy $policy_name does not exist."
    else
        echo "Policy $policy_name exists."
    fi

    # List all attached policies to role DeleteMe
    echo "Listing all attached policies to role $role_name..."
    attached_policies=$(aws iam list-attached-role-policies --role-name "$role_name" --query 'AttachedPolicies[*].PolicyArn' --output text)

    if [ -z "$attached_policies" ]; then
        echo "No policies attached to role $role_name."
    else
        echo "Attached policies:"
        echo "$attached_policies" | tr '\t' '\n'
    fi
fi
