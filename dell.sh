#!/bin/bash

## Template Format ##
bold=`tput bold`
reset=`tput sgr0`

## Template Format Color ##
black=`tput setaf 0`
red=`tput setaf 1`
blue=`tput setaf 4`
yellow=`tput setaf 3`
green=`tput setaf 2`
white=`tput setaf 7`
magenta=`tput setaf 5`

echo "${magenta}${bold}#####################################################################"
echo "## Start Update "
echo "#####################################################################${reset}"
echo "                "

echo "## Valid Username ##"
echo "                    "

if [ -z $1 ]; then
	echo "## ${red}${bold}Error: ${reset}Sorry, Username not informed! But is riquerid. ##"
	echo "## Run the ${green}${bold}dell.sh ${reset}file informing the user name in the parameters. Example: ${green}${bold}dell.sh user${reset} ##"
	exit 1
else
	echo "${yellow}${bold}## Hello, User ${1^} with Username.: $1! ## ${reset}"
	echo "                                                                "
	read -sp 'Enter with Password.: ' passvar
	password=$passvar
fi

echo "## Valid Password ##"
echo "                    "

if [ -z $password ]; then
	echo "## ${red}${bold}Error: ${reset}Sorry, Password not informed! But is riquerid. ##"
	echo "                                                                                "
	exit 1
else
	PASSWORD_ENCODE=`echo -n $password | base64`
fi

echo "## Valid file with password in ${bold}/usr/local/bin ${reset}##"
echo "                                                               "

if [ -e /usr/local/bin/passwd.txt ]; then
	export password_file=$(</usr/local/bin/passwd.txt)
	PASSWORD_ROOT=`echo -n $password_file | base64`
else
	echo "## ${red}${bold}Error: ${reset}File passwd.txt not found in directory /usr/local/bin/. ##"
	echo "## Create the passwd.txt file with your user's password in the /usr/local/bin/ directory. ##"
	echo "                                                                                            "
	exit 1
fi

echo "## Valid User && Password ##"
echo "                            "
if [[ "$1" == "$USER" && "$PASSWORD_ENCODE" == "$PASSWORD_ROOT" ]]; then
	echo "$password_file" | sudo -S -v && sudo apt update && sudo apt upgrade --yes && sudo apt autoclean && sudo apt autoremove --yes
else
	echo "## ${red}${bold}Error: ${reset}Sorry, You not is a root user! =( ##"
	echo "                                                                   "
	exit 1
fi

echo "${magenta}${bold}#####################################################################"
echo "## End Update"
echo "#####################################################################${reset}"
echo "             "
echo "${yellow}${bold}## Bye, ${1^}! by `uname --kernel-name`/`uname --nodename` =) ## ${reset}"
exit 0
