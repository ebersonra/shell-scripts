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

#######################
## Utils's Functions ##
#######################

get_java_path() {
 echo "${magenta}${bold}${format_line}"
 echo "## Init get_java_path()"
 echo "${espace_line}"

 JAVA_PATH=$(cd "$(dirname "$(realpath /etc/alternatives/java)")"; cd ..; pwd)

 echo "## End get_java_path.: $JAVA_PATH"
 echo "${format_line}${reset}"
}

get_text_config() {
 echo "${magenta}${bold}${format_line}"
 echo "## $1 ##"
 echo "${format_line}${reset}"
 echo "${espace_line}"
}
