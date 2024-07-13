#!/bin/bash

# Deploy Networking Stack
aws cloudformation create-stack \
  --stack-name udagram-networking \
  --template-body file://networking.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM

# Wait for Networking Stack to be created
aws cloudformation wait stack-create-complete --stack-name udagram-networking

# Get Outputs from Networking Stack
VPCID=$(aws cloudformation describe-stacks --stack-name udagram-networking --query "Stacks[0].Outputs[?OutputKey=='VPCID'].OutputValue" --output text)
PublicSubnet1ID=$(aws cloudformation describe-stacks --stack-name udagram-networking --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1ID'].OutputValue" --output text)
PublicSubnet2ID=$(aws cloudformation describe-stacks --stack-name udagram-networking --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2ID'].OutputValue" --output text)
PrivateSubnet1ID=$(aws cloudformation describe-stacks --stack-name udagram-networking --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet1ID'].OutputValue" --output text)
PrivateSubnet2ID=$(aws cloudformation describe-stacks --stack-name udagram-networking --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet2ID'].OutputValue" --output text)

# Deploy Application Stack
aws cloudformation create-stack \
  --stack-name udagram-application \
  --template-body file://application.yaml \
  --parameters ParameterKey=VPCID,ParameterValue=$VPCID \
               ParameterKey=PublicSubnet1ID,ParameterValue=$PublicSubnet1ID \
               ParameterKey=PublicSubnet2ID,ParameterValue=$PublicSubnet2ID \
               ParameterKey=PrivateSubnet1ID,ParameterValue=$PrivateSubnet1ID \
               ParameterKey=PrivateSubnet2ID,ParameterValue=$PrivateSubnet2ID \
  --capabilities CAPABILITY_NAMED_IAM

# Wait for Application Stack to be created
aws cloudformation wait stack-create-complete --stack-name udagram-application

# Get Load Balancer DNS Name
LoadBalancerDNSName=$(aws cloudformation describe-stacks --stack-name udagram-application --query "Stacks[0].Outputs[?OutputKey=='LoadBalancerDNSName'].OutputValue" --output text)

# Output Load Balancer DNS Name
echo "Application Load Balancer URL: $LoadBalancerDNSName"
