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


dnf install python3.14 python3.14-pip -y &>>$logs_file
python3.14 --version &>>$logs_file
validation $? "installing python 3.14"

id roboshop &>> $logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
    validate $? "Creating system user"
else
    echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
fi

mkdir /app
curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip &>> $logs_file
validation $? "INSTALLING PAYMENT"

mkdir /app &>> $logs_file
unzip -o /tmp/payment.zip &>> $logs_file
validation $? "UNZIPPING PAYMENT"

cd /app
python3.14 -m venv /app/.venv &>> $logs_file
/app/.venv/bin/pip install -r requirements.txt &>> $logs_file
validation $? "INSTALLING DEPENDENCIES"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/payment.service"
cp "$scripts_dir/payment.service" /etc/systemd/system/payment.service

systemctl daemon-reload
systemctl enable payment
systemctl start payment
validation $? "ENABLE and START PAYMENT"

echo "$(timestamp) [INFO] ==== Script compelted in $SECONDS seconds ====" | tee -a $logs_file
echo "$(timestamp) [INFO] ==== script completed execution ====" | tee -a $logs_file



