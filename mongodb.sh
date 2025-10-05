## This script is to completely automate Mongodb server steps - Installation and configurations ## 

#! /bin/bash 

USERID=$(id -u)

if [ $USERID != 0 ]; then 
    echo "Please login as root user to run the script!"
    else
    echo "Root user verification successful"
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

cp -p /C/DevOps/repos/Roboshop-project/mongodb.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y 
VALIDATE $? "Installing MongoDB"

systemctl enable mongod 
VALIDATE $? "Enabling MongoDB"

systemctl start mongod 
VALIDATE $? "Starting MongoDB"

#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Updating listen address"

systemctl restart mongod
VALIDATE $? "Restarting the service"
