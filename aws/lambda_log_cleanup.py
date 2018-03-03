#!/usr/bin/env python
import boto3

logs = boto3.client('logs')
log_groups = []
retention = 180
prefix = "/aws/lambda/"

print("modifying retention days and deleting empty logs...")

paginator = logs.get_paginator('describe_log_groups')

for page in paginator.paginate(logGroupNamePrefix=prefix):

  for group in page.get('logGroups',[]):
    groupName=group['logGroupName']
    if group['storedBytes'] == 0:
      print("delete: " + groupName)
      logs.delete_log_group(logGroupName=groupName)
      continue
    try:
      if group['retentionInDays'] != retention:
        print("modify: " + groupName)
        logs.put_retention_policy(
          logGroupName=groupName,
          retentionInDays=retention
          )
    except KeyError:
      print("modify: " + groupName)
      logs.put_retention_policy(
        logGroupName=groupName,
        retentionInDays=retention
        )
     
print("done.")
