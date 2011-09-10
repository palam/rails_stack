#!/bin/bash

function apache_virtualhost {
	# Configures a VirtualHost

	# $1 - required - the hostname of the virtualhost to create 

	if [ ! -n "$1" ]; then
		echo "apache_virtualhost() requires the hostname as the first argument"
		return 1;
	fi
	if [ ! -n "$2" ]; then
		echo "apache_virtualhost() requires the username as the second argument"
		return 1;
	fi

	if [ -e "/etc/apache2/sites-available/$1" ]; then
		echo /etc/apache2/sites-available/$1 already exists
		return;
	fi

	mkdir -p /home/$2/sites/$1/public /home/$2/sites/$1/logs

	sudo echo "<VirtualHost *:80>" > /etc/apache2/sites-available/$1
	sudo echo "    ServerName $1" >> /etc/apache2/sites-available/$1
	sudo echo "    DocumentRoot /home/$2/sites/$1/public/" >> /etc/apache2/sites-available/$1
	sudo echo "    ErrorLog /home/$2/sites/$1/logs/error.log" >> /etc/apache2/sites-available/$1
    sudo echo "    CustomLog /home/$2/sites/$1/logs/access.log combined" >> /etc/apache2/sites-available/$1
	sudo echo "</VirtualHost>" >> /etc/apache2/sites-available/$1

	sudo a2ensite $1

	sudo touch /tmp/restart-apache2
}

script_runner=$(whoami)
echo "Enter domain name: "
read domain_name
apache_virtualhost $domain_name $script_runner