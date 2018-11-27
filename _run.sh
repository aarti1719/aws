#!/bin/sh
#set -e

role=$(aws cloudformation describe-stacks --stack-name RDE-API-ROLES --query 'Stacks[0].Outputs[?OutputKey==`CFNRole`].OutputValue' --output text)

###
# Resources
##

file1='file://cfn_resources.yml'
stackname1='RDE-API-PIPELINE-RESOURCES'
changesetname1="$stackname1-$(date +%s)"
if [ "$(aws cloudformation describe-stacks --query 'Stacks[?StackName==`'$stackname1'`].StackName' --output text)" = $stackname1 ]; then
    type1=UPDATE
    waittype1=stack-update-complete
else
    type1=CREATE
    waittype1=stack-create-complete
fi
echo "Creating Changeset..."
id1=$(aws cloudformation create-change-set --stack-name $stackname1 --template-body $file1 --change-set-type $type1 --change-set-name $changesetname1 --capabilities CAPABILITY_IAM --query "Id" --output text --role-arn $role)
status1=$(aws cloudformation describe-change-set --stack-name $stackname1 --change-set-name $changesetname1 --query "Status" --output text)
reason1=$(aws cloudformation describe-change-set --stack-name $stackname1 --change-set-name $changesetname1 --query "StatusReason" --output text)
echo "$changesetname1 STATUS: $status1, REASON: $reason1"
aws cloudformation wait change-set-create-complete --stack-name $stackname1 --change-set-name $changesetname1
status1=$(aws cloudformation describe-change-set --stack-name $stackname1 --change-set-name $changesetname1 --query "Status" --output text)
reason1=$(aws cloudformation describe-change-set --stack-name $stackname1 --change-set-name $changesetname1 --query "StatusReason" --output text)
echo "$changesetname1 STATUS: $status1, REASON: $reason1"
if [ $status1 = "CREATE_COMPLETE" ]; then
    echo "Executing Changeset..."
    aws cloudformation execute-change-set --stack-name $stackname1 --change-set-name $changesetname1
    aws cloudformation wait $waittype1 --stack-name $stackname1 
    aws cloudformation describe-stacks --stack-name $stackname1 --output table 
    echo "$changesetname1 STACK COMPLETE."
fi

###
# Pipeline
###

VpcId='vpc-02267fbf8b2ec8e30'
SubnetIds='subnet-010e9b59b8f280b98'
CodeRepo='RDE-API'
file2='file://cfn_pipe.yml'
params2="ParameterKey=VpcId,ParameterValue=${VpcId} ParameterKey=SubnetIds,ParameterValue=${SubnetIds} ParameterKey=CodeRepo,ParameterValue=${CodeRepo}"
stackname2='RDE-API-PIPELINE-RANI'
changesetname2="$stackname2-$(date +%s)"
if [ "$(aws cloudformation describe-stacks --query 'Stacks[?StackName==`'$stackname2'`].StackName' --output text)" = $stackname2 ]; then
    type2=UPDATE
    waittype2=stack-update-complete
else
    type2=CREATE
    waittype2=stack-create-complete
fi
echo "Creating Changeset..."
id2=$(aws cloudformation create-change-set --stack-name $stackname2 --template-body $file2 --parameters $params2 --change-set-type $type2 --change-set-name $changesetname2 --capabilities CAPABILITY_IAM --query "Id" --output text --role-arn $role)
status2=$(aws cloudformation describe-change-set --stack-name $stackname2 --change-set-name $changesetname2 --query "Status" --output text)
reason2=$(aws cloudformation describe-change-set --stack-name $stackname2 --change-set-name $changesetname2 --query "StatusReason" --output text)
echo "$changesetname2 STATUS: $status2, REASON: $reason2"
aws cloudformation wait change-set-create-complete --stack-name $stackname2 --change-set-name $changesetname2
status2=$(aws cloudformation describe-change-set --stack-name $stackname2 --change-set-name $changesetname2 --query "Status" --output text)
reason2=$(aws cloudformation describe-change-set --stack-name $stackname2 --change-set-name $changesetname2 --query "StatusReason" --output text)
echo "$changesetname2 STATUS: $status2, REASON: $reason2"
if [ $status2 = "CREATE_COMPLETE" ]; then
    echo "Executing Changeset..."
    aws cloudformation execute-change-set --stack-name $stackname2 --change-set-name $changesetname2
    aws cloudformation wait $waittype2 --stack-name $stackname2 
    aws cloudformation describe-stacks --stack-name $stackname2 --output table 
    echo "$changesetname2 STACK COMPLETE."
fi
