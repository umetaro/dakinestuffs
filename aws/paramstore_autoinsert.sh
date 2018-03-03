#!/bin/bash

while read -r line
do
  array=( ${line} )
  subnetid="${array[0]}"
  cidr="${array[1]}"
  az="${array[2]}"

  aws ssm put-parameter --name "/mappings/vpc/subnet/${az}/id" --description "${cidr}" --value "${subnetid}" --type "String"
done < <(aws ec2 describe-subnets --query 'Subnets[].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==`Name`] | [0].Value ]' --output text | awk '{ print $1" "$3" "$4 }' | column -t)


