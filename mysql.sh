#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-log"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"
VALIDATE(){
    if [ $1 -ne 0 ]
        then
            echo -e "$2 ...... $R FAILURE $N"
            exit 1
        else
            echo -e "$2 ...... $G SUCCESS $N"
    fi           
}
CHEK_ROOT(){
    if [ $USERID -ne 0 ]
        then
            echo " ERROR:: you must have sudo access to excute this script"
            exit 1
    fi

}
    echo "script starting executing at: $TIMESTAMP" &>>$LOG_FILE_NAME
CHEK_ROOT

    dnf install mysql-server -y &>>$LOG_FILE_NAME
    VALIDATE $? "installing MYSQL server"

    systemctl enable mysqld &>>$LOG_FILE_NAME
    VALIDATE $? "enable MYSQL server"

    systemctl start mysqld &>>$LOG_FILE_NAME
    VALIDATE $? "starting MYSQL server"

    mysql -h mysql.mogili.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME


if [ $? -ne 0 ]
    then
        echo "MYSQL Root password not setup" &>>$LOG_FILE_NAME
        mysql_secure_installation --set-root-pass ExpenseApp@1
        VALIDATE $? "setting Root password"
    else
        echo -e "MYSQL Root password already setup ..... $Y SKIPPING $N"
fi