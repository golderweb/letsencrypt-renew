#!/bin/bash
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin

# Get all existing inifiles matching namescheme cli-${domain}.ini
for inifile in cli-*.ini; do

	# Strip domain out of filename
	domain=${inifile:4:-4}

	# sleep for a random time so not all certificates get renewed at the same time
	sleep $(expr $RANDOM % 600)

	# Check validity of cert for domain
	openssl x509 -checkend $(( 21 * 86400 )) -in ~/.config/letsencrypt/live/${domain}/cert.pem > /dev/null

	if [ \$? != 0 ]; then
		# run let's encrypt
		letsencrypt certonly -c ~/.config/letsencrypt/cli-${domain}.ini
		# import certificate
		uberspace-add-certificate -k ~/.config/letsencrypt/live/${domain}/privkey.pem -c ~/.config/letsencrypt/live/${domain}/cert.pem
	fi

done
