##########################
## Template Format Line ##
##########################
format_line="#####################################################################"
espace_line="                                                                     "

##########################
## Template Format Font ##
##########################
bold=`tput bold`

###########################
## Template Reset Format ##
###########################
reset=`tput sgr0`

###########################
## Template Format Color ##
###########################
black=`tput setaf 0`
red=`tput setaf 1`
blue=`tput setaf 4`
yellow=`tput setaf 3`
green=`tput setaf 2`
white=`tput setaf 7`
magenta=`tput setaf 5`

#################
## Utils's ENV ##
#################
JAVA_VERSION=$1
JAVA_PATH="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"
GRADLE_VERSION=""
DOWNLOAD_DIR="/home/$USER/Downloads"

#######################
## Utils's Functions ##
#######################

getJavaPath() {
 echo "${magenta}${bold}${format_line}"
 echo "## Init get_java_path()"
 echo "${espace_line}"

 JAVA_PATH=$(cd "$(dirname "$(realpath /etc/alternatives/java)")"; cd ..; pwd)

 echo "## End get_java_path.: $JAVA_PATH"
 echo "${format_line}${reset}"
}

getTextConfig() {
 echo "${magenta}${bold}${format_line}"
 echo "## $1 ##"
 echo "${format_line}${reset}"
 echo "${espace_line}"
}

installDefaultJdkJre() {
 echo "## Init install_default_jdk_jre()"
 echo "$1" | sudo -S -v && sudo apt install default-jre --yes && sudo apt install default-jdk --yes && echo "JAVAC VERSION: `javac -version`" && echo "JAVA VERSION: `java -version`"
 echo "## End install_default_jdk_jre()"
}

installOpenjdkJreByVersion() {
 echo "## Init install_openjdk_jre_by_version"
 echo "$1" | sudo -S -v && sudo apt install openjdk-${JAVA_VERSION}-jre --yes && sudo apt install openjdk-${JAVA_VERSION}-jdk --yes && echo "JAVAC VERSION: `javac -version`" && echo "JAVA VERSION: `java -version`"
 echo "## End install_openjdk_jre_by_version"
}

addJavaHomeInFileEnvironment(){
 echo "## Int add_java_home_in_file_environment()"
 echo "$1" | sudo -S -v && sudo sed -i -e '$aJAVA_HOME="'${JAVA_PATH}'"' /etc/environment && source /etc/environment
 echo "## End add_java_home_in_file_environment()"
}

validFormatVersion() {
 
 local version=$1
 local text_version="[ ${bold}${green}OK${reset} ] Version valid formart v"

 if [[ $version == ?.?.? ]]; then
 	logInfo "${text_version}${version}"
 elif [[ $version == ?.?? ]]; then
 	logInfo "${text_version}${version}"
 elif [[ $version == ?.??.? ]]; then
	logInfo "${text_version}${version}"
 elif [[ $version == ?.?? ]]; then
	logInfo "${text_version}${version}"
 elif [[ $version == ?.? ]]; then
	logInfo "${text_version}${version}"
 else
	echo "${espace_line}"
 	logInfo "[ ${bold}${red}x${reset} ] Version invalid format v$version"
	exit 1
 fi
}

logInfo(){
 local message=$1
 echo "${espace_line}"
 echo "## $message"
}

logError(){
 local message=$1
 echo "${bold}${red}### Error.:${reset} $message"
}

getVersionGradle(){

 if [ -z "$GRADLE_VERSION" ]; then	 
  logInfo "GET Last Gradle Version......"
  curl -s https://gradle.org/releases/ | grep -o "<span>v[^>]*</span>" | tr -d '<span/>' > $(pwd)/versions.txt
  logInfo "End GET Last Gradle Version......."
 fi

 while [[ "$GRADLE_VERSION" == "" ]]
 do 
	 IFS= read -r line
	 logInfo "Last Gradle Version.: $line"
	 if [ $line != "" ]; then
		line=$(echo "${line//v/}")
	 	GRADLE_VERSION=$line
	 fi

 done < "$(pwd)/versions.txt"
}

downloadGradleZipFile(){
 logInfo "Saved in $DOWNLOAD_DIR"
 wget https://services.gradle.org/distributions/gradle-"$1"-all.zip -P "$DOWNLOAD_DIR"
}
