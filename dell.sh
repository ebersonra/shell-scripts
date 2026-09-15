#!/bin/bash

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"

if [ -e "${script_dir}/lib/common.sh" ]; then
	. "${script_dir}/lib/common.sh"
else
	. /usr/local/bin/lib/common.sh
fi

login_user="${SUDO_USER:-$USER}"
username="${1:-$login_user}"

echo "${magenta}${bold}${format_line}"
echo "## Start Update "
echo "${format_line}${reset}"
echo "${espace_line}"

echo "## Valid Username ##"
echo "${espace_line}"

echo "${yellow}${bold}## Hello, User ${username^} with Username.: ${username}! ## ${reset}"
echo "${espace_line}"

if [[ "${username}" != "${login_user}" ]]; then
	echo "## ${red}${bold}Error: ${reset}Username ${username} does not match the logged-in user ${login_user}. ##"
	echo "## Run ${green}${bold}dell.sh${reset} or ${green}${bold}dell.sh ${login_user}${reset} ##"
	echo "${espace_line}"
	exit 1
fi

echo "## Valid file with password in ${bold}/usr/local/bin ${reset}##"
echo "${espace_line}"

if [ -e /usr/local/bin/passwd.txt ]; then
	password_file=$(</usr/local/bin/passwd.txt)
	password_file="${password_file%%$'\r'}"
	password_file="${password_file%%$'\n'}"
	export password_file
else
	echo "## ${red}${bold}Error: ${reset}File passwd.txt not found in directory /usr/local/bin/. ##"
	echo "## Create the passwd.txt file with your user's password in the /usr/local/bin/ directory. ##"
	echo "${espace_line}"
	exit 1
fi

run_apt_update() {
	sudo apt update && sudo apt upgrade --yes && sudo apt autoclean && sudo apt autoremove --yes
}

echo "## Valid User && Password ##"
echo "${espace_line}"

if [[ "${EUID}" -eq 0 ]]; then
	run_apt_update
else
	read -rsp 'Enter with Password.: ' password
	echo
	echo "${espace_line}"

	if [ -z "${password}" ]; then
		echo "## ${red}${bold}Error: ${reset}Sorry, Password not informed! But is required. ##"
		echo "${espace_line}"
		exit 1
	fi

	PASSWORD_ENCODE=$(printf '%s' "${password}" | base64)
	PASSWORD_ROOT=$(printf '%s' "${password_file}" | base64)

	if [[ "${PASSWORD_ENCODE}" != "${PASSWORD_ROOT}" ]]; then
		echo "## ${red}${bold}Error: ${reset}Password does not match /usr/local/bin/passwd.txt. ##"
		echo "${espace_line}"
		exit 1
	fi

	printf '%s\n' "${password_file}" | sudo -S -v && run_apt_update
fi

echo "${magenta}${bold}${format_line}"
echo "## End Update"
echo "${format_line}${reset}"
echo "${espace_line}"
echo "${yellow}${bold}## Bye, ${username^}! by `uname --kernel-name`/`uname --nodename` =) ## ${reset}"
exit 0
