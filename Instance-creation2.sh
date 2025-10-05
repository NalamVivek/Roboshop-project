# Below command is to create Instance through CLI. For which, CLI Installation and configuration should be completed. 
# Later to that we are extracting IP's based on instance ID. 
# Later to that we are updating route53 records. 

#! /bin/bash

AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-0ca74d0228955aa4a


for INSTANCE in $@
do 
    #INSTANCE CREATION THROUGH CLI
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" --query 'Instances[0].InstanceId' --output text)

    #Get IP based on condition
    if [ $INSTANCE != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        #RECORD_NAME="$instance.$DOMAIN_NAME"
        else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        #RECORD_NAME="$DOMAIN_NAME"
    fi 

    echo "$INSTANCE: $IP"

done


#=================================#
## Updating route53 records ##
#=================================#


#    aws route53 change-resource-record-sets \
#    --hosted-zone-id $ZONE_ID \
#    --change-batch '
#    {
#        "Comment": "Updating record set"
#        ,"Changes": [{
#        "Action"              : "UPSERT"
#        ,"ResourceRecordSet"  : {
#            "Name"              : "'$RECORD_NAME'"
#            ,"Type"             : "A"
#            ,"TTL"              : 1
#            ,"ResourceRecords"  : [{
#               "Value"         : "'$IP'"
#            }]
#        }
#        }]
#    }
#    '
