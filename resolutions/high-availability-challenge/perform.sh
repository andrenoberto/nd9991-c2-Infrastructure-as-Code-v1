#!/bin/bash
action=$1
template=$2
accountId=001536788864
stackName=udagram
serversStackName=udagramServers
jumpBoxesStackName=udagramJumpBoxes
# Create Actions
if [ $action = 'create' ]
then
  if [ $template = 'network' ]
  then
    # Creates network infrastructure
    aws cloudformation $action-stack --stack-name $stackName --region us-west-2 --template-body file://./templates/network.yml --parameters file://./templates/network-parameters.json
    # Creates key pair
    aws ec2 create-key-pair --key-name $stackName --query 'KeyMaterial' --output text > assets/$stackName.pem
    # Creates S3 bucket
    aws s3 mb s3://$stackName-$accountId
    # Uploads required files
    aws s3 cp assets/$stackName.pem s3://$stackName-$accountId/$stackName.pem
    aws s3 cp assets/udagram.zip s3://$stackName-$accountId/udagram.zip
  elif [ $template = 'servers' ]
  then
    aws cloudformation $action-stack --stack-name $serversStackName --region us-west-2 --template-body file://./templates/servers.yml --parameters file://./templates/servers-parameters.json --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
  elif [ $template = 'jumpbox' ]
  then
    aws cloudformation $action-stack --stack-name $jumpBoxesStackName --region us-west-2 --template-body file://./templates/jumpbox.yml --parameters file://./templates/jumpbox-parameters.json
  fi
fi
# Delete Actions
if [ $action = 'delete' ]
then
  if [ $template = 'network' ]
  then
    aws cloudformation $action-stack --stack-name $stackName
    # Deletes the bucket and its content
    aws s3 rb s3://$stackName-$accountId --force
    # Deletes the key pair
    aws ec2 delete-key-pair --key-name $stackName
  elif [ $template = 'servers' ]
  then
    aws cloudformation $action-stack --stack-name $serversStackName
  elif [ $template = 'jumpbox' ]
  then
    aws cloudformation $action-stack --stack-name $jumpBoxesStackName
  fi
fi
