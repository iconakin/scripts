#!/usr/bin/bash

# Delete the credentials.txt file
rm -f credentials.txt

USERNAME=$2
PASSWORD=$3
addUser()
{
    # Condition to check if PASSWORD is empty. If so, it generates a random password
    if [ -z $3]
    then
        PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
    fi

    # Create a file to store user's credentials
    touch credentials.txt

    # Write USERNAME and PASSWORD to credentials.txt
    echo "Hello $USERNAME, here are your login credentials:" >> credentials.txt
    echo ""
    echo "Username: " $USERNAME >> credentials.txt
    echo "Password: " $PASSWORD >> credentials.txt


    # This first line is to add a user that is passed as an argument
    sudo useradd $USERNAME

    # This second command adds the username and password entered in that order to the right side of the pipe
    echo $USERNAME:$PASSWORD | sudo chpasswd

    # Copy rules file into users home directory
    # sudo cp companyrules.txt /home/$USERNAME/

    # Send success message to the admin running the script
    echo "$USERNAME has been successfully created, well done!"
}

deleteUser()
{
    sudo userdel -r $USERNAME
    echo "$USERNAME has been deleted!"
}

if [ $1 == "add" ]
then
    addUser
elif [$1 == "remove" ]
then
    deleteUser
else
    echo "You need to specify either [add] or [remove]"
fi