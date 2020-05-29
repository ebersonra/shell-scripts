#!/bin/bash

echo "==================== Start Update =========================="
echo "                                                            "
echo "                                     "
echo "   ***********         ***********   "
echo "        (**)             (**)        "
echo "   ***********         ***********   "
echo "                                     "
echo "                                     "
echo "              =========              "
echo "           ===============           "
echo "         ===================         "
echo "           ===============           "
echo "                                                            "
echo "                                                            "

read -p 'Username.: ' uservar
read -sp 'Password.: ' passvar

#==================================================
#==================================================

if [ -z $uservar ]; then
	echo "Sorry, Username not informed! But is riquerid."
	exit 1
else
	echo "                                                            "
	echo "Hello, User ${uservar^} with Username.: $uservar!"
	echo "                                                            "
fi

#==================================================
#==================================================

if [ -z $passvar ]; then
	echo "Sorry, Password not informed! But is riquerid."
	exit 1
else
	PASSWORD_ENCODE=`echo -n $passvar | base64`
fi

#===================================================
#===================================================
PASSWORD_ROOT="UmFtb3NAOTk="

if [[ "$uservar" == "$USER" && "$PASSWORD_ENCODE" == "$PASSWORD_ROOT" ]]; then
	sudo apt update && sudo apt upgrade --yes && sudo apt autoclean && sudo apt autoremove --yes
else
	echo "Sorry, You not is a Root User! =("
	exit 1
fi

echo "==================== End Update ============================"
echo "                                                            "
echo "Bye, $uservar! by `uname --kernel-name`/`uname --nodename` =)"
exit 0
