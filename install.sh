#!/bin/bash

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
clear
echo "  * Installation des dépendances pour Scribe-WebDAV *  "
apt-get install libapache2-mod-authnz-external pwauth -y
log_msg_green "  * mod_authnz et pwauth ..."
a2enmod authnz_external
service apache2 reload
echo "AddExternalAuth pwauth /usr/sbin/pwauth" >> /etc/apache2/httpd.conf
echo "SetExternalAuthMethod pwauth pipe" >> /etc/apache2/httpd.conf
log_msg_green " * a2enmod et ajout en conf httpd ..." 
service apache2 reload
chmod u+s /usr/sbin/pwauth
log_msg_green " * Droits d'execution sur pwauth pour www-data ..." 
log_msg_green " * Fin du script ..." 

