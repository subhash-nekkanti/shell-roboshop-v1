#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file=${logs_folder}/${0}.log

domain_name="devops92s.shop"

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


dnf module disable nodejs -y
dnf module enable nodejs:24 -y
validation $? "Disbaling existing node js and Enabling v24"

dnf install nodejs -y
validation $? "INSTALLING NODEJS:24"
id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validation $? "CREATING SYSTEM USER"
else
    echo -e "$(timestamp) [INFO] SYSTEM USER already EXIST so ${Y}SKIPPING${N}"
fi

mkdir /app
curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip

sed -i "s/DOMAIN_NAME/$domain_name/g" user.service

validation $? "DOWNLOADING USER"

cd /app
unzip -o /tmp/user.zip
validation $? "UNZIPPING user"

cd /app
npm install
validation $? "INSTALLING DEPENDENCIES"

systemctl daemon-reload
validation $? "RELOAD USER"

systemctl enable user
systemctl start user
validation $? "ENABLE and START USER"



echo "$(timestamp) [INFO] ==== Script compelted in $SECONDS seconds ====" | tee -a $logs_file
echo "$(timestamp) [INFO] ==== script completed execution ====" | tee -a $logs_file



