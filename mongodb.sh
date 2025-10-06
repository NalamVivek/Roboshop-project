## This script is to completely automate Mongodb server steps - Installation and configurations ## 

#! /bin/bash 


SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FOLDER="/home/ec2-user/Roboshop-project/logs"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER

USERID=$(id -u)

if [ $USERID != 0 ]; then 
    echo "Please login as root user to run the script!"
    exit 1
    else
    echo "Root user verification successful."
fi 

VALIDATE()
{
    if [ $1 != 0 ]; then 
        echo "$2 failed..Exiting"
        exit 1
        else
        echo "$2 successful"
    fi  
}

cp -p /home/ec2-user/Roboshop-project/mongodb.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod 
VALIDATE $? "Enabling MongoDB"

systemctl start mongod 
VALIDATE $? "Starting MongoDB"

#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Updating listen address"

systemctl restart mongod
VALIDATE $? "Restarting the service is"
