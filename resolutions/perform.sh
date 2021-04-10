#!/bin/bash
if [ $1 = 'delete' ]
then
  aws cloudformation $1-stack --stack-name $2
else
  aws cloudformation $1-stack --stack-name $2 --region us-west-2 --template-body file://$3 --parameters file://$4
fi
