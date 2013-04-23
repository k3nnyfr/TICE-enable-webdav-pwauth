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

DIRECTORY=/var/www/webdav/

if ! test -d $DIRECTORY;
then
	log_msg_red " * Répertoire WebDAV n'existe pas ! ..."
	mkdir /var/www/webdav/
	log_msg_green " * Répertoire WebDAV ajouté"
	cp webdav-base /etc/apache2/sites-available/webdav
	# Dossier de base WebDAV admin/admin
	#cp .passwd-base.dav /var/www/webdav/.passwd-base.dav
	a2ensite webdav
	service apache2 reload
else
	log_msg_green " * Le répertoire racine WebDAV existe deja"
fi


# - Lecture CSV utilisateurs - 
# Lecture fichier compte_webdav
# 
INPUT=compte_webdav.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

# - Boucle de création -
# Lien sympbolique depuis dossier utilisateur vers dossier webdav dans /var/www/webdav/
# Création du fichier contenant le login/password webdav 
# Droits corrects sur le fichier passwd.dav
# Copie du fichier de conf webdav-$userlogin
# Remplacement des variables dans le fichier conf Apache
# Activation du site via a2ensite
#

while read user_login password
do
	log_msg_green " * Login : $user_login ... "
	if [ ! -d "/home/$user_login/webdav/" ]
	then
		mkdir /home/$user_login/webdav/
		chown $user_login:www-data /home/$user_login/webdav/
        	chmod g+w /home/$user_login/webdav/
		log_msg_green "  * Dossier WebDAV perso de $user_login ajouté..." 
	else
		log_msg_red " * Dossier WebDAV perso de $user_login existe déjà ..." 
	fi
	if [ ! -L /var/www/webdav/$user_login ]
	then
		ln -s /home/$user_login/webdav/ /var/www/webdav/$user_login
		log_msg_green "  * Lien symbolique dossier WebDAV utilisateur -> serveur Web ... "
	else
		log_msg_red " * Lien symbolique existe déjà"
	fi
	#htpasswd -cb /var/www/webdav/$user_login/.passwd.dav $user_login $password > /dev/null
	#log_msg_green "   * Création mot de passe pour acces WebDAV ...."
	#chown www-data:www-data /var/www/webdav/$user_login/.passwd.dav
	#log_msg_green "   * Droits sur le fichier .passwd .... [*]"
	if [ ! -f "/etc/apache2/sites-available/webdav-$user_login" ]
	then
		cp webdav-model "/etc/apache2/sites-available/webdav-$user_login"
		log_msg_green "   * Copie du fichier de conf Apache2 model ...."
		sed 's/STRINGTOREPLACE/'$user_login'/g' webdav-model > /etc/apache2/sites-available/webdav-$user_login 
		log_msg_green "   * Modification dans le fichier de conf Apache2 ...."
		site="webdav-"$user_login
		a2ensite $site
		log_msg_green "   * Activation du fichier de conf Apache2 ...."
	else
		log_msg_red " * ERREUR : Acces WebDAV pour $user_login existe déjà ..."
	fi
done < $INPUT
IFS=$OLDIFS
	service apache2 reload
	log_msg_green " * Reload d'Apache2 ...."
