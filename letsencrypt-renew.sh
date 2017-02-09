#!/bin/bash
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin

# sleep for a random time so not all certificates get renewed at the same time
sleep 473

openssl x509 -checkend $(( 21 * 86400 )) -in ~/.config/letsencrypt/live/${domain}/cert.pem > /dev/null

if [ \$? != 0 ]; then
	# run let's encrypt
	letsencrypt certonly
	# import certificate
	uberspace-add-certificate -k ~/.config/letsencrypt/live/${domain}/privkey.pem -c ~/.config/letsencrypt/live/${domain}/cert.pem
fi
