## This script is to completely automate catalogue server steps - Installation and configurations ## 

#! /bin/bash 

SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FOLDER="/home/ec2-user/Roboshop-project/logs"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.speakaholics.fun

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

dnf module disable nodejs -y
VALIDATE $? "Disabling NodeJS default version is"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJS V20 is"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

#Adding application User based on condition

id roboshop
if [ $? != 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating System user"
    else
    echo "User already exist..Skipping.."
fi 

#Creating app directory and downloading code into it. 

mkdir -p /app  #create if not available
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
rm -rf /app/*
VALIDATE $? "Removing existing code"
unzip /tmp/catalogue.zip
VALIDATE $? "Downloading code to app directory"

cd /app 
npm install 
VALIDATE $? "Installing dependencies"

systemctl daemon-reload

systemctl enable catalogue 
systemctl start catalogue

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... SKIPPING"
fi

systemctl restart catalogue
VALIDATE $? "Restarted catalogue"