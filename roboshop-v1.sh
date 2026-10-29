#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
hostedzone_id="Z09125131M9EG1Q5WH8KL"
domain_name="devops92s.shop"

for instance in $@
do
    echo "creating instance"
    
    instance_id=$(aws ec2 run-instances \
                    --image-id $ami_id
                    --instance_type $instance_type \
                    --security-groups "Roboshop-common" "roboshop-$instance" \
                    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-$instance}]"
                    --query 'Instances[0].InstanceId' \
                    --output text)
    echo "$instance ID is: $instance_id"

done
