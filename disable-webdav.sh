#!/bin/bash
#
# - Base - 
# Création du dossier webdav si inexistant
# Copie du fichier de conf webdav de base
#
clear

log_msg_green() {
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    NORMAL=$(tput sgr0)
    MSG="$1"
    let COL=$(tput cols)-${#MSG}+${#GREEN}+${#NORMAL}

    printf "%s%${COL}s" "$MSG" "$GREEN[OK]$NORMAL"
}

log_msg_red() {
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    NORMAL=$(tput sgr0)
    MSG="$1"
    let COL=$(tput cols)-${#MSG}+${#RED}+${#NORMAL}

    printf "%s%${COL}s" "$MSG" "$RED[NOK]$NORMAL"
}

log_msg_green " * Debut du traitement de suppression ..." 

INPUT=compte_webdav.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

#rm /var/www/webdav/.passwd-base.dav
while read user_login password
do
		if [ -L "/var/www/webdav/$user_login" ]
		then
			rm /var/www/webdav/$user_login
			log_msg_green " * Suppression du compte WebDAV : $user_login ..."
			log_msg_green " * Suppression récurrsive du repertoire WebDAV de $user_login ..."
		fi
		if [ -d /home/$user_login/webdav/ ]
		then		
			rm -R /home/$user_login/webdav/
		fi
		if [ -f /etc/apache2/sites-available/webdav-$user_login ]
		then
			site="webdav-"$user_login
			a2dissite $site
			rm /etc/apache2/sites-available/webdav-$user_login
		fi
done < $INPUT
IFS=$OLDIFS
if [ -f /etc/apache2/sites-available/webdav ]
then
	a2dissite webdav
	rm /etc/apache2/sites-available/webdav
	rm -R /var/www/webdav/
	log_msg_green "  * Site principal WebDAV desactive..."
	service apache2 reload
else
	log_msg_red " * Rien a desactiver ..."
fi
