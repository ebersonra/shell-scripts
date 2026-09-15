#!/bin/bash

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"

if [ -f "${script_dir}/lib/common.sh" ]; then
	. "${script_dir}/lib/common.sh"
	getTextConfig "Get common file in ${script_dir}/lib"
else
	. /usr/local/bin/lib/common.sh
	getTextConfig "Get common file in /usr/local/bin/lib"
fi

while [ -z "$firts_name" ]
do
	echo -n "${bold}## What's your firts name?${reset} "
	IFS= read firts_name
done

while [ -z "$last_name" ]
do
	echo -n "${bold}## What's your last name?${reset} "
	IFS= read last_name
done

COMPLETE_NAME=${firts_name^}" "${last_name^}
logInfo "Set $COMPLETE_NAME for git user.name config global"
git config --global user.name "$COMPLETE_NAME"

while [ -z "$username" ]
do
	echo -n "${bold}## What's your username?${reset} "
	IFS= read username
done

logInfo "Set $username for git user.email config global"
git config --global user.email "$username"

getTextConfig "Lsit All Configurations"
git config --list

getTextConfig "End Git Config"

