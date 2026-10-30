#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file=${logs_folder}/${0}.log

mkdir -p $logs_folder

# echo -e "\e[31mThis is Red Text\e[0m"    is the syntax for colours numbers denote colours and -e tells that it is enabling something 
R="\e[31m"
G="\e[32m" #instead of repeating this command every where we are storing it in a variables 
Y="\e[33m"
N="\e[0m"


timestamp(){          #timstamp function insted date "+%f %T" command everywhere just call the function when needed
    date "+%F %T"
}


validation(){
    if [ "$1" -ne 0 ]; then # $? gives the exit status of previous command if it is 0 then only it proceeds to next steps
        echo "$(timestamp) [ERROR]  ${2}..FAILED" | tee -a $logs_file
    exit 1  #(nginxxxxx) installation failed (exit status is not 0) so it just prints and terminates it wont install my sql
    else 
        echo "$(timestamp) [INFO]  ${2}..SUCCESS" | tee -a $logs_file
    fi
}

if [ $user_id -ne 0 ]; then
    echo "please run this script with sudo access"
    exit 1
fi

echo "$(timestamp) [INFO] ==== script started execution ====" | tee -a $logs_file

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validation $? "Adding Rabbitmq Repo"

dnf install erlang rabbitmq-server -y &>>$logs_file
validation $? "Installing RabbitMQ server"

systemctl enable rabbitmq-server &>>$logs_file
systemctl start rabbitmq-server &>>$logs_file
validation $? "Start and Enable RabbtiMQ server"

#Idempotency: A script or program should give same result irrespective of no of times we run or retries the script


rabbitmqctl list_users | grep -qw "roboshop"                    #if systemuser already exists and if we run this script multiple times it throws error for adding user
if [ $? -ne 0 ]; then                                           #so check if user already exist or nor with command "rabbitmq ctl list_users | grep -qw "roboshop" and check exit status 
    rabbitmqctl add_user roboshop roboshop123 &>>$logs_file      #if exit status is 0 then user already exist and skip creating user. If $? =1 then create a user which means user doesnot exist
    validation $? "creating system RabbitMQ user for RoboShop"
else
    echo -e "$(timestamp) [INFO] : User already exist ${Y}SKIPPING...${N}" 
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$logs_file
validation $? "Set Permissions for system user" 



echo "$(timestamp) [INFO] ==== Script compelted in $SECONDS seconds ====" | tee -a $logs_file
echo "$(timestamp) [INFO] ==== script completed execution ====" | tee -a $logs_file




