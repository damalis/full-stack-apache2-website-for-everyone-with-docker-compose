#!/bin/sh
set -e

if [ -z $1 ]; then
	echo "DOMAIN environment variable is not set"
	exit 1;
fi

if [ ! -f $2/ssl-dhparam.pem 2>/dev/null ]; then
	openssl dhparam -out $2/ssl-dhparam.pem 2048
fi

use_lets_encrypt_certificates() {
	echo "switching webserver to use Let's Encrypt certificate for $1"
	sed -i 's/example.com/'$1'/g' $3/extra/httpd-ssl.conf
	sed '/^#\(.*\)httpd-ssl\.conf/ s/^#//' $3/httpd.conf > $3/httpd.conf.bak
	sed 's/#LoadModule/LoadModule/' $3/extra/httpd-vhosts.conf > $3/extra/httpd-vhosts.conf.bak
}

reload_apache2() {
	cp $1/httpd.conf.bak $1/httpd.conf
	cp $1/extra/httpd-vhosts.conf.bak $1/extra/httpd-vhosts.conf
	rm $1/httpd.conf.bak
	rm $1/extra/httpd-vhosts.conf.bak
	echo "Starting webserver apache2 service"
	httpd -t
}

wait_for_lets_encrypt() {
	if [ -d "$2/live/$1" ]; then
		break 
	else
		until [ -d "$2/live/$1" ]; do
			echo "waiting for Let's Encrypt certificates for $1"
			sleep 5s & wait ${!}
			if [ -d "$2/live/$1" ]; then break; fi
		done
	fi;
	use_lets_encrypt_certificates "$1" "$2" "$3"
	reload_apache2 "$3"
}

for domain in $1; do
	if [ ! -d "$2/live/$1" ]; then
		wait_for_lets_encrypt "$domain" "$2" "$3" &
	else
		use_lets_encrypt_certificates "$domain" "$2" "$3"
		reload_apache2 "$3"
	fi
done

httpd-foreground
