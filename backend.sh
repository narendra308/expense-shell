#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense.log"
LOG_FILE=$(echo $0 | cut -d '.' -f1)
TIMESTAMP=$(date +%d-%m-%y-%H-%M-%S)
LOG_FILE_NAME=$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP
VALIDATE(){
    if [ $1 -ne 0 ]
        then
            echo -e "$2 ....... $R FAILURE $N"
            exit 1
        else
            echo  -e"$2 ....... $G SUCCESS $N"
    fi

}
CHEK_ROOT(){
    if [ $USERID -ne 0 ]
        then
            echo "ERROR:: you must have sudo access to execu this script"
            exit 1
    fi
}
echo "script starting and executing at: $TIMESTAMP" &>>$LOG_FILE_NAME
CHEK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling existing Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Nodejs"

useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "Adding expense user"

mkdir /app &>>$LOG_FILE_NAME
VALIDATE $? "Creacting app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading backend"

cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unziping backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

# preparing schema

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MYSQL client"

mysql -h mysql.mogili.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting up the transactions schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling backend service"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "Start backend service"