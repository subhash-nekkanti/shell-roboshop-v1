#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file=${logs_folder}/${0}.log
mkdir -p $logs_folder
domain_name="devops92s.shop"
scripts_dir=$(dirname "$(realpath "$0")")


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
validation $? "Disable Node JS existing Version"

dnf module enable nodejs:24 -y &>>$logs_file
validation $? "Enable Node JS V 24"

dnf install nodejs -y &>>$logs_file
validation $? "Installing Node JS"
                
id roboshop &>>$logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$logs_file
    validation $? "Creating system user"
else
    echo -e "$(timestamp) [INFO] System user already exist ${Y}SKIPPING...${N}"
fi

mkdir -p /app &>>$logs_file #creating app directory -p tells if /app is already existing leave if not thrn create /app directory
validation $? "Creating Appp directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>>$logs_file
validation $? "downloading the application"

cd /app
unzip -o /tmp/catalogue.zip &>>$logs_file
validation $? "Unzipping application"

cd /app
npm install &>>$logs_file
validation $? "Installing Dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" $scripts_dir/catalogue.service &>>$logs_file
cp $scripts_dir/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload &>>$logs_file
validation $? "Reloading application"

systemctl enable catalogue &>>$logs_file
validation $? "Enabling application"

systemctl start catalogue &>>$logs_file
validation $? "Starting application (catalogue)"


cp $scripts_dir/mongo.repo /etc/yum.repos.d/mongo.repo &>>$logs_file
validation $? "Loading Master Data(MongoDB)"

dnf install mongodb-mongosh -y &>>$logs_file
validation $? "Installing MongoDB Client"

test=$"mongosh --host mongodb.$domain_name --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()'"
if [ $test -ne 0 ]; then
    echo -e "Data has been already loaded so ${y}SKIPPING...${n}"
    
else
    mongosh --host mongodb.$domain_name --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' &>>$logs_file
    validation $? "Loading data"
fi

echo "$(timestamp) [INFO] ==== Script compelted in $SECONDS seconds ====" | tee -a $logs_file
echo "$(timestamp) [INFO] ==== script completed execution ====" | tee -a $logs_file




