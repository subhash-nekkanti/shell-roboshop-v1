#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file=${logs_folder}/${0}.log

domain_name="devops92s.shop"

scriptdir=$(dirname "$(realpath "$0")")
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


dnf module disable nodejs -y &>>$logs_file
dnf module enable nodejs:24 -y &>>$logs_file
validation $? "Disbaling existing node js and Enabling v24"

dnf install nodejs -y &>>$logs_file
validation $? "INSTALLING NODEJS:24"
id roboshop &>>$logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$logs_file
    validation $? "CREATING SYSTEM USER"
else
    echo -e "$(timestamp) [INFO] SYSTEM USER already EXIST so ${Y}SKIPPING${N}"
fi

mkdir /app &>>$logs_file
curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip &>>$logs_file

sed -i "s/DOMAIN_NAME/$domain_name/g" cart.service &>>$logs_file
validation $? "DOWNLOADING CART"

cd /app
unzip -o /tmp/cart.zip &>>logs_file
validation $? "UNZIPPING CART"

cd /app
npm install &>>logs_file
validation $? "INSTALLING DEPENDENCIES"

cp $scriptdir/cart.service /etc/systemd/system/cart.service &>>$logs_file

systemctl daemon-reload &>>$logs_file
validation $? "RELOAD CART"

systemctl enable cart &>>$logs_file
systemctl start cart &>>$logs_file
validation $? "ENABLE and START CART"



echo "$(timestamp) [INFO] ==== Script compelted in $SECONDS seconds ====" | tee -a $logs_file
echo "$(timestamp) [INFO] ==== script completed execution ====" | tee -a $logs_file



