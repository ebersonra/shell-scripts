#!/bin/bash

echo "==================== Start Update =========================="
echo "                                                            "
echo "[Progress 0%] [|..................................................................................................................]"

#==================================================
#==================================================

if [ -z $1 ]; then
	echo "Sorry, Username not informed! But is riquerid."
	echo "Run the dell.sh file informing the user name in the parameters. Example: dell.sh user"
	exit 1
else
	echo "                                                            "
	echo "Hello, User ${1^} with Username.: $1!"
	echo "                                                            "
	read -sp 'Password.: ' passvar
	password=$passvar
fi

#==================================================
#==================================================

if [ -z $password ]; then
	echo "Sorry, Password not informed! But is riquerid."
	exit 1
else
	PASSWORD_ENCODE=`echo -n $password | base64`
fi

#===================================================
#===================================================
if [ -e /usr/local/bin/passwd.txt ]; then
	echo "[Progress 50%] [||||||||||||||||||||||||||||||||||||||||||||||||||.........................................................]"
	password_file=$(</usr/local/bin/passwd.txt)
	PASSWORD_ROOT=`echo -n $password_file | base64`
else
	echo "File passwd.txt not found in directory /usr/local/bin/."
	echo "Create the passwd.txt file with your user's password in the /usr/local/bin/ directory."
	exit 1
fi

if [[ "$1" == "$USER" && "$PASSWORD_ENCODE" == "$PASSWORD_ROOT" ]]; then
	echo "$password_file" | sudo -S -v && sudo apt update && sudo apt upgrade --yes && sudo apt autoclean && sudo apt autoremove --yes
else
	echo "Sorry, You not is a Root User! =("
	exit 1
fi

echo "[Progress 100%] [|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||]"
echo "==================== End Update ============================"
echo "                                                            "
echo "Bye, ${1^}! by `uname --kernel-name`/`uname --nodename` =)"
exit 0
