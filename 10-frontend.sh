#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file=${logs_folder}/${0}.log

domain_name="devops92s.shop"

scripts_dir=$(dirname "$(realpath "$0")")
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

dnf module disable nginx -y
dnf module enable nginx:1.26 -y
dnf install nginx -y
validation $? "INSTALLING NGINX"

systemctl enable nginx
systemctl start nginx
validation $? "ENABLE AND START NGINX"

rm -rf /usr/share/nginx/html/*
validation $? "remove old content"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip
validation $? "INSTALLING FRONTEND PACKAGE"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
validation $? "UNZIPPING FRONTEND"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/roboshop.conf"
cp "$scripts_dir/roboshop.conf" /etc/systemd/system/roboshop.conf


systemctl restart nginx
validation $? "START nginx"

echo "$(timestamp) [INFO] ==== Script compelted in $SECONDS seconds ====" | tee -a $logs_file
echo "$(timestamp) [INFO] ==== script completed execution ====" | tee -a $logs_file



