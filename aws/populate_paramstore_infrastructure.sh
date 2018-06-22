#!/usr/bin/env bash

PRODSUBNETS=""
STAGESUBNETS=""
MGMTSUBNETS=""

while read -r line
do
  array=( ${line} )

  # skip default vpc
  [[ ${array[2]} =~ ^172 ]] && continue 

  # assign subnet values
  subnetid="${array[0]}"
#  az="${array[1]}"
  cidr="${array[2]}"
  name="${array[3]}"
  env="$( echo "${name}" | awk -F- '{ print $1 }' )"
  tier="$( echo "${name}" | awk -F- '{ print $3 }' )"
  aznum="$( echo "${name}" | awk -F- '{ print $4 }' )"

  # populate subnetid list for use after loop
  [[ ${env} == "prod" ]] && export PRODSUBNETS="${subnetid},${PRODSUBNETS}"
  [[ ${env} == "stage" ]] && export STAGESUBNETS="${subnetid},${STAGESUBNETS}"
  [[ ${env} == "mgmt" ]] && export MGMTSUBNETS="${subnetid},${MGMTSUBNETS}"

  #  echo "0: $subnetid  1: $az  2: $cidr  3: $tier  4: $env  5: $aznum"
  aws ssm put-parameter --name "/${env}/vpc/${aznum}/${tier}/id" --value "${subnetid}" --type "String" --overwrite
  aws ssm put-parameter --name "/${env}/vpc/${aznum}/${tier}/cidr" --value "${cidr}" --type "String" --overwrite
done < <(aws ec2 describe-subnets --query 'Subnets[].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==`Name`] | [0].Value ]' --output text | column -t)

prodsubnetids="${PRODSUBNETS//,$//}"
aws ssm put-parameter --name "/Production/vpc/subnetIds" --value "${prodsubnetids}" --type "String" --overwrite
stagesubnetids="${STAGESUBNETS//,$//}"
aws ssm put-parameter --name "/Staging/vpc/subnetIds" --value "${stagesubnetids}" --type "String" --overwrite
mgmtsubnetids="${MGMTSUBNETS//,$//}"
aws ssm put-parameter --name "/Management/vpc/subnetIds" --value "${mgmtsubnetids}" --type "String" --overwrite
