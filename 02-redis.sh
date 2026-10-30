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

dnf module disable redis -y &>>$logs_file
validation $? "Disabling old Redis version"

dnf module enable redis:7 -y &>>$logs_file
validation $? "Enable redis  V7"

dnf install redis -y &>>$logs_file
validation $? "Redis Installation"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>>$logs_file
validation $? "configuration"  # 1. strating with bind chnage 127.0.0.1 to 0.0.0.0 and also
                               #2. substitute protected-mode yes to protected-mode no (peermanantly -i)

systemctl enable redis
systemctl start redis
validation $? "Enable and start redis"



echo "$(timestamp)[INFO] ==== Time Taken ==== $SECONDS" | tee -a $logs_file
echo "$(timestamp)[INFO] ==== script completed execution ====" | tee -a $logs_file




