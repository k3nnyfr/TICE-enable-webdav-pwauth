TICE-enable-webdav-pwauth
=========================

Enable WebDAV user directory from CSV file for EOLE Scribe with PAM pwauth that works!

Script to enable WebDAV for users on a Scribe server (French Educational server)

Pre-requisites
------------
- Install.sh script launched
- a2enmod dav
- a2enmod dav_fs

Description
------------

What it does :
- Create the base directory /var/www/webdav/
- Copy a site config file and enables it for that base directory
- Reload apache2

- Import a CSV file containing user login
- Create a symbolic link from user directory webdav to website directory
- Copy and modify a model config file and enables it
- Reload apache2

That script works super fine with PWauth, a mod for mod_authnz_external which enable login

from linux regular login/password 

Usage
------------

- Edit compte-webdav.csv to add several users
- Launch install.sh to install dependencies and several minors things to do like so : ./install.sh
- Launch enable-webdav.sh script like so : ./enable-webdav.sh
- Watch the result by going to your account via an Internet browser : http://ip/webdav/user/
- A user and password box should prompt and you should access user webdav dir
- You can reverse that with disable-webdav.sh 
