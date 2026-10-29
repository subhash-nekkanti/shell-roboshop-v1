#!/bin/bash
#storing all common ids and nmaes that are common for all instances into variables
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
hostedzone_id="Z09125131M9EG1Q5WH8KL"
domain_name="devops92s.shop"

for instance in $@ #creating a instance by taking arguments dynamicaly...it takes all the args and create instances ex:mongodb,cart,user,mysql etc...
do
    echo "creating instance"
    
    instance_id=$(aws ec2 run-instances \
                    --image-id $ami_id \
                    --instance-type $instance_type \
                    --security-groups "Roboshop-common" "roboshop-$instance" \
                    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-$instance}]" \
                    --query 'Instances[0].InstanceId' \
                    --output text)
    echo "$instance Instance ID is: $instance_id"



#getting private and public ips and creating r53_record names
    if [ $instance != "frontend" ]; then #if the instance is not frontend we need private ip of frontend to update in  r53
        IP=$(aws ec2 describe-instances \
                --instance-ids $instance_id \
                --query 'Reservations[*].Instances[*].[PrivateIpAddress]' \
                --output text)
        echo "privateIp is : $IP"
        r53_record="$instance.$domain_name"   #if the instance is not frontend we name record with instance.domain_name....ex:roboshop-mongodb.devops92s.shop

    else
        IP=$(aws ec2 describe-instances \      #if the instance is frontend we need public ip to update in r53
                --instance-ids $instance_id \      
                --query 'Reservations[*].Instances[*].[PublicIpAddress]' \
                --output text)
        echo "public IP is : $IP"
        r53_record="$domain_name"   #if the instance is frontend we name record with domain_name itself...ex:devops92s.shop

    fi
    
#update Route53 record
echo "record : $r53_record"
aws route53 change-resource-record-sets \
    --hosted-zone-id $hostedzone_id \
    --change-batch '{
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$domain_name'",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [{"Value": "' $IP'"}]
            }
        }]
    }'

    echo "r53 updated succesfully for $instance

done
