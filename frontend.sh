#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER=/var/log/expense.log/
LOG_FILE=$(echo $0 | cut -d '.' -f1)
TIMESTAMP=$(date %y-%m-%d-%H-%M-%S)
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
            echo "ERROR:: you must have sudo access to execute this script"
            exit 1
    fi
}

            echo " script starting and execucting at: $TIMESTAMP"
CHEK_ROOT