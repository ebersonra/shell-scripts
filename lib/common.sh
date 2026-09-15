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
ADOPTIUM_API="https://api.adoptium.net/v3"
ADOPTIUM_RELEASES_URL="https://adoptium.net/pt-BR/temurin/releases"
TEMURIN_INSTALL_ROOT="/opt/java"
TEMURIN_ARCHIVE_NAME=""
ADOPTIUM_LTS=""
ADOPTIUM_ALL=""
ADOPTIUM_MOST_RECENT_LTS=""

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

 echo "$password" | sudo -S -v && sudo sed -i '/^JAVA_HOME/ d' /etc/environment
 echo "$password" | sudo -S -v && sudo sed -i -e '$aJAVA_HOME="'${JAVA_PATH}'"' /etc/environment && source /etc/environment
 export JAVA_HOME="${JAVA_PATH}"
 updateFileEnv "${JAVA_PATH}/bin"
 
 logInfo "End addJavaHomeInFileEnvironment()"
}

getAdoptiumArch() {
 case "$(uname -m)" in
  x86_64) echo "x64" ;;
  aarch64|arm64) echo "aarch64" ;;
  *)
   logError "Unsupported architecture.: $(uname -m)"
   exit 1
   ;;
 esac
}

listAdoptiumReleases() {
 logInfo "Init listAdoptiumReleases() from ${ADOPTIUM_RELEASES_URL}"

 local json
 local json_compact
 json=$(curl -fsSL "${ADOPTIUM_API}/info/available_releases")
 if [ -z "$json" ]; then
  logError "Failed to fetch Temurin releases from Adoptium API"
  exit 1
 fi

 json_compact=$(echo "$json" | tr -d '\n')
 ADOPTIUM_LTS=$(echo "$json_compact" | grep -o '"available_lts_releases"[[:space:]]*:[[:space:]]*\[[^]]*\]' | grep -o '[0-9]\+' | tr '\n' ' ' | sed 's/[[:space:]]*$//')
 ADOPTIUM_ALL=$(echo "$json_compact" | grep -o '"available_releases"[[:space:]]*:[[:space:]]*\[[^]]*\]' | grep -o '[0-9]\+' | tr '\n' ' ' | sed 's/[[:space:]]*$//')
 ADOPTIUM_MOST_RECENT_LTS=$(echo "$json_compact" | grep -o '"most_recent_lts"[[:space:]]*:[[:space:]]*[0-9]\+' | grep -o '[0-9]\+$')

 if [ -z "$ADOPTIUM_ALL" ] || [ -z "$ADOPTIUM_MOST_RECENT_LTS" ]; then
  logError "Failed to parse Temurin releases from Adoptium API"
  exit 1
 fi

 echo "${bold}## Temurin releases (Adoptium).:${reset} ${ADOPTIUM_RELEASES_URL}"
 echo "${espace_line}"
 echo "${bold}## LTS available.:${reset} ${green}${ADOPTIUM_LTS}${reset}"
 echo "${bold}## All available.:${reset} ${ADOPTIUM_ALL}"
 echo "${bold}## Most recent LTS.:${reset} ${green}${ADOPTIUM_MOST_RECENT_LTS}${reset}"
 echo "${espace_line}"

 logInfo "End listAdoptiumReleases()"
}

isAdoptiumReleaseAvailable() {
 local version=$1
 local release

 for release in $ADOPTIUM_ALL; do
  if [ "$release" = "$version" ]; then
   return 0
  fi
 done
 return 1
}

isValidTemurinArchive() {
 local archive=$1
 local magic

 if [ ! -f "$archive" ] || [ ! -s "$archive" ]; then
  return 1
 fi

 # Temurin ships gzip-compressed tar (.tar.gz); reject plain tar/HTML/partial downloads
 magic=$(od -An -tx1 -N2 "$archive" 2>/dev/null | tr -d ' \n')
 if [ "$magic" != "1f8b" ]; then
  return 1
 fi

 gzip -t "$archive" 2>/dev/null || return 1
 return 0
}

downloadTemurinJdk() {
 local version=$1
 local arch
 local binary_url
 local package_link
 local archive_path

 logInfo "Init downloadTemurinJdk() version ${version}"

 arch=$(getAdoptiumArch)
 binary_url="${ADOPTIUM_API}/binary/latest/${version}/ga/linux/${arch}/jdk/hotspot/normal/eclipse?project=jdk"
 package_link=$(curl -fsSI "$binary_url" | grep -i '^location:' | awk '{print $2}' | tr -d '\r')

 if [ -z "$package_link" ]; then
  logError "Failed to resolve Temurin download URL for JDK ${version}"
  exit 1
 fi

 TEMURIN_ARCHIVE_NAME=$(basename "$package_link" | sed 's/%2B/+/g')
 archive_path="${DOWNLOAD_DIR}/${TEMURIN_ARCHIVE_NAME}"
 mkdir -p "$DOWNLOAD_DIR"

 if isValidTemurinArchive "$archive_path"; then
  logInfo "Archive already exists.: ${archive_path}"
 else
  if [ -e "$archive_path" ]; then
   logInfo "Invalid cached archive removed.: ${archive_path}"
   rm -f "$archive_path"
  fi

  logInfo "Download Temurin JDK ${version}.: ${package_link}"
  wget --progress=bar:force:noscroll -O "$archive_path" "$package_link"

  if ! isValidTemurinArchive "$archive_path"; then
   rm -f "$archive_path"
   logError "Downloaded file is not a valid Temurin .tar.gz archive"
   exit 1
  fi
 fi

 logInfo "End downloadTemurinJdk() ${TEMURIN_ARCHIVE_NAME}"
}

installTemurinJdk() {
 local password=$1
 local version=$2
 local extract_dir
 local extracted_jdk
 local archive_path

 logInfo "Init installTemurinJdk() version ${version}"

 archive_path="${DOWNLOAD_DIR}/${TEMURIN_ARCHIVE_NAME}"
 if [ -z "$TEMURIN_ARCHIVE_NAME" ] || ! isValidTemurinArchive "$archive_path"; then
  logError "Temurin archive not found or invalid in ${DOWNLOAD_DIR}"
  exit 1
 fi

 echo "$password" | sudo -S -v && sudo mkdir -p "$TEMURIN_INSTALL_ROOT"
 extract_dir=$(mktemp -d "${DOWNLOAD_DIR}/temurin-${version}-XXXXXX")
 if ! tar -xzf "$archive_path" -C "$extract_dir"; then
  rm -rf "$extract_dir"
  logError "Failed to extract Temurin archive ${TEMURIN_ARCHIVE_NAME}"
  exit 1
 fi

 extracted_jdk=$(find "$extract_dir" -mindepth 1 -maxdepth 1 -type d | head -1)
 if [ -z "$extracted_jdk" ] || [ ! -x "${extracted_jdk}/bin/java" ]; then
  rm -rf "$extract_dir"
  logError "Invalid Temurin archive content"
  exit 1
 fi

 JAVA_PATH="${TEMURIN_INSTALL_ROOT}/jdk-${version}"
 echo "$password" | sudo -S -v && sudo rm -rf "$JAVA_PATH"
 echo "$password" | sudo -S -v && sudo mv "$extracted_jdk" "$JAVA_PATH"
 rm -rf "$extract_dir"

 logInfo "End installTemurinJdk() ${JAVA_PATH}"
 echo "JAVA VERSION: $(${JAVA_PATH}/bin/java -version 2>&1 | head -1)"
 echo "JAVAC VERSION: $(${JAVA_PATH}/bin/javac -version 2>&1)"
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

 if [ ! -s "$(pwd)/versions.txt" ]; then	 
  
	 logInfo "--> GET Last Gradle Version <--"
  	 
	 local latest_version
	 latest_version=$(curl -s https://services.gradle.org/versions/current | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | grep -o '[0-9][0-9.]*')
	 if [ -z "$latest_version" ]; then
		logError "Failed to get last Gradle version"
		exit 1
	 fi
	 echo "v${latest_version}" > "$(pwd)/versions.txt"
  
  	 logInfo "--> End GET Last Gradle Version <--"
 else
	 logInfo "GET Last Gradle Version from cache in file ${bold}versions.txt${reset}"
 fi

 while IFS= read -r line || [ -n "$line" ]
 do 
	 logInfo "Last Gradle Version.: $line"
	 if [ -n "$line" ]; then
		line="${line//v/}"
	 	GRADLE_VERSION=$line
		break
	 fi
 done < "$(pwd)/versions.txt"

 if [ -z "$GRADLE_VERSION" ]; then
	logError "Failed to resolve Gradle version from versions.txt"
	exit 1
 fi
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

 logInfo "Init updateFileEnv()"

 if [[ ! $PATH == *"$new_parameter" ]]; then
 	
	NEW_PATH=${PATH}:${new_parameter}
 	getPassword "/usr/local/bin"
	 
 	echo "$PASSWORD_FILE" | sudo -S -v && sudo sed -i '/^PATH/ d' /etc/environment
 	echo "$PASSWORD_FILE" | sudo -S -v && sudo sed -i -e '$aPATH="'${NEW_PATH}'"' /etc/environment && source /etc/environment

 	cat /etc/environment
 else
	 logInfo "$new_parameter exists in environment ${bold}PATH${reset}"
 fi

 logInfo "End updateFileEnv()"
}

