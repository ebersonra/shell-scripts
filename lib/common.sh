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
PASSWORD_FILE=""

#######################
## Utils's Functions ##
#######################

getJavaPath() {
 echo "${magenta}${bold}${format_line}"
 logInfo "Init getJavaPath()"
 echo "${espace_line}"

 JAVA_PATH=$(cd "$(dirname "$(realpath /etc/alternatives/java)")"; cd ..; pwd)

 logInfo "End getJavaPath() $JAVA_PATH"
 echo "${format_line}${reset}"
}

getTextConfig() {
 local text=$1

 echo "${magenta}${bold}${format_line}"
 echo "## $text ##"
 echo "${format_line}${reset}"
 echo "${espace_line}"
}

installDefaultJdkJre() {
 local password=$1

 logInfo "Init installDefaultJdkJre()"
 echo "$password" | sudo -S -v && sudo apt install default-jre --yes && sudo apt install default-jdk --yes && echo "JAVAC VERSION: `javac -version`" && echo "JAVA VERSION: `java -version`"
 logInfo "End installDefaultJdkJre()"
}

installOpenjdkJreByVersion() {
 local password=$1

 logInfo "Init installOpenjdkJreByVersion()"
 echo "$password" | sudo -S -v && sudo apt install openjdk-${JAVA_VERSION}-jre --yes && sudo apt install openjdk-${JAVA_VERSION}-jdk --yes && echo "JAVAC VERSION: `javac -version`" && echo "JAVA VERSION: `java -version`"
 logInfo "End installOpenjdkJreByVersion()"
}

addJavaHomeInFileEnvironment(){
 local password=$1

 logInfo "Init addJavaHomeInFileEnvironment()"
 echo "$password" | sudo -S -v && sudo sed -i -e '$aJAVA_HOME="'${JAVA_PATH}'"' /etc/environment && source /etc/environment
 updateFileEnv "$JAVA_PATH"
 logInfo "End addJavaHomeInFileEnvironment()"
}

validFormatVersion() {
 local version=$1
 local text_version="[ ${bold}${green}OK${reset} ] Version valid formart v"

 logInfo "Init validFormatVersion()"
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
 logInfo "Init validFormatVersion()"
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

 if [ ! -f $(pwd)/versions.txt ]; then	 
  logInfo "GET Last Gradle Version......"
  curl -s https://gradle.org/releases/ | grep -o "<span>v[^>]*</span>" | tr -d '<span/>' > $(pwd)/versions.txt
  logInfo "End GET Last Gradle Version......."
 else
  logInfo "GET Last Gradle Version from cache in file ${bold}versions.txt${reset}"
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
 local version=$1

 logInfo "Saved in $DOWNLOAD_DIR"
 wget https://services.gradle.org/distributions/gradle-"$version"-all.zip -P "$DOWNLOAD_DIR"
}

createGradleDir(){
 local password=$1
 local dir_name=$2

 echo "$password" | sudo -S -v && sudo mkdir -p "/opt/$dir_name"
 logInfo "Create directory ${bold}/opt/$dir_name${reset}"
 GRADLE_PATH=$(cd /opt/${dir_name}; pwd)
}

unzipFile(){
 local dir_name=$1
 local file_name=$2
 local password=$3

 logInfo "Unzip file.: ${bold}From${reset} $DOWNLOAD_DIR ${bold}To${reset} $dir_name"
 if [ -e "$DOWNLOAD_DIR/$file_name" ]; then
  echo "$password" | sudo -S -v && sudo unzip ${DOWNLOAD_DIR}/$file_name -d $dir_name
  CODE_RESULT=0
 else
  logError "Unzip not found file in `echo $DOWNLOAD_DIR`"
  CODE_RESULT=1
 fi
}

getPassword(){
 local dir_name=$1

 logInfo "GET Password in path ${bold}$dir_name${reset}"
 if [ -e "${dir_name}/passwd.txt" ]; then
 	PASSWORD_FILE=$(<${dir_name}/passwd.txt)
 fi
}

addGradleInPathEnv(){
 local path_file=$1

 logInfo "${bold}${green}Actual PATH${reset} `echo $PATH`"
 if [ -d "$path_file/bin" ]; then
 	
	updateFileEnv "${path_file}/bin"
 else
	logError "Directory not found"
 fi
}

updateFileEnv(){
 local new_parameter=$1

 NEW_PATH=${PATH}:${new_parameter}
 getPassword "/usl/local/bin"

 logInfo "Init updateFileEnv()"
			 
 echo "$PASSWORD_FILE" | sudo -S -v && sudo sed -i '/^PATH/ d' /etc/environment
 echo "$PASSWORD_FILE" | sudo -S -v && sudo sed -i -e '$aPATH="'${NEW_PATH}'"' /etc/environment && source /etc/environment

 cat /etc/environment
}

