#!/bin/bash

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"

if [ -e "${script_dir}/lib/common.sh" ]; then
	. "${script_dir}/lib/common.sh" $1
else
	. /usr/local/bin/lib/common.sh $1
fi

echo "${magenta}${bold}## Hi, ${USER^}! =) ##${reset}"
echo "${espace_line}"

if [ -z "$JAVA_VERSION" ]; then
	getTextConfig "1) Config JDK/JRE (Adoptium Temurin)"
else
	getTextConfig "1) Config JDK/JRE Version $JAVA_VERSION (Adoptium Temurin)"
fi

echo "## Valid if Default JDK/JRE exist in env JAVA_HOME ##"
echo "${espace_line}"

echo "## JDK/JRE.: `echo $JAVA_HOME` ##"
echo "${espace_line}"

echo "## PATH.: `source /etc/environment && echo $PATH` ##"
echo "${espace_line}"

if [ -n "$JAVA_HOME" ]; then
	echo "${yellow}${bold}${format_line}"
	echo "## `echo $JAVA_HOME` is installed and configured ##"
	echo "${format_line}${reset}"
	echo "${espace_line}"

	echo "${bold}JAVA VERSION: `java -version 2>&1 | head -1`"
	echo "${espace_line}"

	echo "JAVAC VERSION: `javac -version 2>&1`${reset}"
	echo "${espace_line}"
else
	echo "## JDK/JRE no exist in JAVA_HOME ##"
	echo "${espace_line}"
fi

typeset -l install_java_answer="i"
while [[ "$install_java_answer" != "y" && "$install_java_answer" != "n" ]]
do
	echo -n "${bold}## Do you want to install a new JDK version from Adoptium Temurin?${reset} ${red}[y] or [n]${reset}${bold}.:${reset} "
	IFS= read install_java_answer
done

if [ "$install_java_answer" == "y" ]; then
	echo "## Init install JDK/JRE from Adoptium Temurin ##"
	echo "${espace_line}"
	echo "## Releases.: ${ADOPTIUM_RELEASES_URL} ##"
	echo "${espace_line}"

	if [ -e "${script_dir}/dell.sh" ]; then
		"${script_dir}/dell.sh" $USER
		error_code=$?
	else
		/usr/local/bin/dell.sh $USER
		error_code=$?
	fi

	if [ "$error_code" -ne "0" ]; then
		logError "Failed to executed shell script ${green}${bold}dell.sh ${reset}"
		exit $error_code
	fi

	getPassword "/usr/local/bin"
	password_file="${PASSWORD_FILE}"
	if [ -z "$password_file" ]; then
		logError "File passwd.txt not found in /usr/local/bin"
		exit 1
	fi

	listAdoptiumReleases

	if [ -z "$JAVA_VERSION" ]; then
		echo -n "${bold}## What's your Temurin JDK version?${reset} ${red}Ex: ${ADOPTIUM_MOST_RECENT_LTS}${reset}${bold}.:${reset} "
		IFS= read JAVA_VERSION
	else
		echo "## Using Temurin JDK version from args.: ${JAVA_VERSION} ##"
		echo "${espace_line}"
	fi

	if [ -z "$JAVA_VERSION" ]; then
		JAVA_VERSION="$ADOPTIUM_MOST_RECENT_LTS"
		echo "## Empty version. Using most recent LTS.: ${JAVA_VERSION} ##"
		echo "${espace_line}"
	fi

	if ! isAdoptiumReleaseAvailable "$JAVA_VERSION"; then
		logError "JDK version ${JAVA_VERSION} is not available on Adoptium Temurin"
		echo "## Available.: ${ADOPTIUM_ALL} ##"
		exit 1
	fi

	getTextConfig "Download Temurin JDK ${JAVA_VERSION}"
	downloadTemurinJdk "$JAVA_VERSION"

	getTextConfig "Install Temurin JDK ${JAVA_VERSION} in ${TEMURIN_INSTALL_ROOT}"
	installTemurinJdk "${password_file}" "$JAVA_VERSION"

	echo "## Config JAVA_HOME in ${bold}/etc/environment ${reset}##"
	echo "${espace_line}"

	if [ -d "$JAVA_PATH" ]; then
		echo "## Directory ${bold}${JAVA_PATH} ${reset}exists. ##"
		echo "${espace_line}"

		addJavaHomeInFileEnvironment "${password_file}"

		echo "## Add Temurin JDK `echo $JAVA_HOME` ##"
		echo "${espace_line}"
	else
		logError "Directory ${JAVA_PATH} does not exists."
		echo "${espace_line}"
		exit 1
	fi
elif [ -z "$JAVA_HOME" ]; then
	logError "JAVA_HOME is empty and install was skipped"
	exit 1
else
	echo "## Keeping current JDK/JRE configuration ##"
	echo "${espace_line}"
fi

getTextConfig "End 1) Config JDK/JRE"

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
	getPassword "/usr/local/bin"
	createGradleDir $PASSWORD_FILE "gradle"
	unzipFile $GRADLE_PATH "gradle-${gradle_version}-all.zip" $PASSWORD_FILE
	
	if [ "$CODE_RESULT" == 0 ]; then
		addGradleInPathEnv "${GRADLE_PATH}/gradle-${gradle_version}"
	fi
fi

getTextConfig "End 2) Config Gradle"

echo "${magenta}${bold}## End config env dev. Bye, ${USER^}! by `uname --kernel-name`/`uname --nodename` ;) ## ${reset}"
exit 0
