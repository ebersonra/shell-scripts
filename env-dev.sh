#!/bin/bash

path_common=$(pwd)

if [ -e "${path_common}"/lib/common.sh ];then
	. ${path_common}/lib/common.sh $1
else
	. /usr/local/bin/lib/common.sh $1
fi

echo "${magenta}${bold}## Hi, ${USER^}! =) ##${reset}"
echo "${espace_line}"

echo "## Configuration initial the of environment for developer ##"
echo "${espace_line}"

if [ -z "$JAVA_VERSION" ]; then
	get_text_config "1) Config Default JDK/JRE"
else
	get_text_config "1) Config JDK/JRE Version $JAVA_VERSION"
fi

echo "## Valid if Default JDK/JRE exist in env JAVA_HOME ##"
echo "${espace_line}"

echo "## JDK/JRE.: `echo $JAVA_HOME` ##"
echo "${espace_line}"

echo "## PATH.: `echo $PATH` ##"
echo "${espace_line}"

if [ -z "$JAVA_HOME" ]; then
	echo "## JDK/JRE no exist. Init install JDK/JRE ##"
	echo "${espace_line}"

		if [ -e $(pwd)/dell.sh ]; then
			$(pwd)/dell.sh $USER
			error_code=$?
		else
			/usr/local/bin/dell.sh $USER
			error_code=$?
		fi

		if [ "$error_code" -ne "0" ];then
			echo "${reset}## ${red}${bold}Error: ${reset}Failed to executed shell script ${green}${bold}dell.sh ${reset}##"
			exit $error_code
		fi

		echo "## Install JDK/JRE ##"
		echo "${espace_line}"
		
		if [ -z "$JAVA_VERSION" ]; then
			echo "## Install Default JDK/JRE"
			echo "${espace_line}"
			
			install_default_jdk_jre "${password_file}"

			get_java_path
		else
			echo "## Install JDK/JRE Version $JAVA_VERSION"
			echo "${espace_line}"
			
			install_openjdk_jre_by_version "${password_file}"

			get_java_path
		fi

		echo "## Config JAVA_HOME in ${bold}/etc/environment ${reset}##"
		echo "${espace_line}"
		
		if [ -d "$JAVA_PATH" ]; then
			
			echo "## Directory ${bold}${JAVA_PATH} ${reset}exists. ##"
			echo "${espace_line}"

			add_java_home_in_file_environment "${password_file}"

			echo "## Add Default JDK/JRE `echo $JAVA_HOME` ##"
			echo "${espace_line}"
		else
			echo "## ${red}${bold}Error: ${reset}Directory ${JAVA_PATH} does not exists. ##"
			echo "${espace_line}"
			exit 100
		fi
else
	echo "${yellow}${bold}${format_line}"
	echo "## `echo $JAVA_HOME` is installed and configured ##"
	echo "${format_line}${reset}"
	echo "${espace_line}"
	
	echo "${bold}JAVA VERSION: `java -version`"
	echo "${espace_line}"
	
	echo "JAVAC VERSION: `javac -version`${reset}"
	echo "${espace_line}"
fi

get_text_config "End 1) Config Default JDK/JRE"

get_text_config "2) Config Gradle"

get_text_config "End 2) Config Gradle"

echo "${magenta}${bold}## End config env dev. Bye, ${USER^}! by `uname --kernel-name`/`uname --nodename` ;) ## ${reset}"
exit 0
