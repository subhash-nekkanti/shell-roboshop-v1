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




validation(){
    if [ "$1" -ne 0 ]; then # $? gives the exit status of previous command if it is 0 then only it proceeds to next steps
        echo "${2} FAILED" | tee -a $logs_file
    exit 1  #(nginxxxxx) installation failed (exit status is not 0) so it just prints and terminates it wont install my sql
    else 
        echo "${2} SUCCESS" | tee -a $logs_file
    fi
}

if [ $user_id -ne 0 ]; then
    echo "please run this script with sudo access"
    exit 1
fi


cp mongo.repo /etc/yum.repos.d/mongo.repo
validation $? "adding mongo repo"

dnf install mongodb-org -y &>>logs_file
validation $? "MongoDB installation"

systemctl enable mongod &>>logs_file
systemctl start mongod &>>logs_file
validation $? "starting and enabling MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf   #sed-streamline editor, -i make changes permanantly s--> substitute
validation $? "updating remote configuation"     #127.0.0.1 to 0.0.0.0 in /etc/mongod.conf

systemctl restart mongod  #restarting mongoDB
validation $? "Restarting mongoDB"

