# tf-stackset-cleanup

Example in using StackSets to delete obsolete resources across many accounts

```
aws iam create-role --role-name DeleteMe --assume-role-policy-document "$(jq -n --arg service "ec2.amazonaws.com" '{Version: "2012-10-17", Statement: [{Effect: "Allow", Principal: {Service: $service}, Action: "sts:AssumeRole"}]}' )"
```

# TODO

- [ ] - StackSet with EventBridge Scheduler
- [ ] - StackSet with custom Lambda