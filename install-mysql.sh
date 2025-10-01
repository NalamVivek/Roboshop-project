#This script will install my sql server into your server if run with root access. 

#! /bin/bash

User_status=$(id -u)

if [ $User_status -ne 0]; then 
    echo "Login with root user to run this script!"

    else
        dnf install mysql-server -y 
        Exit_Status=$($?)

        if [ Exit_Status -ne 0]; then 
            echo "MySql server installation failed."
            
            else
                echo "MySql server installation successfull!"
        fi
fi