#!/bin/bash

path_common=$(pwd)

if [ -e "${path_common}"/lib/common.sh ]; then
	. ${path_common}/lib/common.sh $1
else
	. /usr/local/bin/lib/common.sh $1
fi

echo "${magenta}${bold}## Hi, ${USER^}! =) ##${reset}"
echo "${espace_line}"

echo "## Configuration initial the of environment for developer ##"
echo "${espace_line}"

if [ -z "$JAVA_VERSION" ]; then
	getTextConfig "1) Config Default JDK/JRE"
else
	getTextConfig "1) Config JDK/JRE Version $JAVA_VERSION"
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

		if [ "$error_code" -ne "0" ]; then
			logError "Failed to executed shell script ${green}${bold}dell.sh ${reset}"
			exit $error_code
		fi

		echo "## Install JDK/JRE ##"
		echo "${espace_line}"
		
		if [ -z "$JAVA_VERSION" ]; then
			echo "## Install Default JDK/JRE"
			echo "${espace_line}"
			
			installDefaultJdkJre "${password_file}"

			getJavaPath
		else
			echo "## Install JDK/JRE Version $JAVA_VERSION"
			echo "${espace_line}"
			
			installOpenjdkJreByVersion "${password_file}"

			getJavaPath
		fi

		echo "## Config JAVA_HOME in ${bold}/etc/environment ${reset}##"
		echo "${espace_line}"
		
		if [ -d "$JAVA_PATH" ]; then
			
			echo "## Directory ${bold}${JAVA_PATH} ${reset}exists. ##"
			echo "${espace_line}"

			addJavaHomeInFileEnvironment "${password_file}"

			echo "## Add Default JDK/JRE `echo $JAVA_HOME` ##"
			echo "${espace_line}"
		else
			logError "Directory ${JAVA_PATH} does not exists."
			echo "${espace_line}"
			exit 1
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

getTextConfig "End 1) Config Default JDK/JRE"

getTextConfig "2) Config Gradle"

# force to lowercase
typeset -l answer="i"

while [[ "$answer" != "y" && "$answer" != "n" ]]
do
 echo -n "${bold}## Do you have a specific version?${reset} ${red}[y] or [n]${reset}${bold}.:${reset} "
 IFS= read answer
done

typeset -l user_answer=$answer

if [ "$user_answer" == "y" ]; then	
	echo -n "${bold}## What's your version?${reset} ${red}Ex: v4.10.5${reset}${bold}.: v${reset}" 
        read version
        gradle_version=$version

	validFormatVersion $gradle_version

        getTextConfig "Download specific version gradle.: gradle-${gradle_version}"
else
	getVersionGradle
	gradle_version="$GRADLE_VERSION"
	
	getTextConfig "Download last version gradle.: gradle-${gradle_version}"
fi	

#Valida se ja existe
if [[ -d /opt/gradle && -d /opt/gradle/gradle-${gradle_version} ]]; then
	#Mostra uma mensagem que já existe uma versao configurada
	getTextConfig "Gradle v${gradle_version} exist in /opt/gradle"
	getTextConfig "Not is necessarily a new download"

else
	getTextConfig "Init Download Gradle.: gradle-${gradle_version}"
	#Faz o download da versao informada
	downloadGradleZipFile $gradle_version

	#Apos o download adiciona no /etc/enviroment

	#Unzip para /opt/
	getPassword
	createGradleDir $PASSWORD_FILE "gradle"
	unzipFile $GRADLE_PATH "gradle-${gradle_version}-all.zip" $PASSWORD_FILE
	
	if [ "$CODE_RESULT" == 0 ]; then
		addGradleInPathEnv "${GRADLE_PATH}/gradle-${gradle_version}"
	fi
fi

getTextConfig "End 2) Config Gradle"

echo "${magenta}${bold}## End config env dev. Bye, ${USER^}! by `uname --kernel-name`/`uname --nodename` ;) ## ${reset}"
exit 0
