#!/bin/bash
#
#  letsencrypt-renew.sh
#
#  Copyright 2017 Jonathan Golder <jonathan@golderweb.de>
#
#  Derived from:
#    https://wiki.uberspace.de/webserver:https#automatisieren_von_let_s_encrypt
#  Which is itself originaly based on:
#    https://github.com/nerdoc/uberspace-tools/blob/master/letsencrypt-renew
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#

PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin

# PATH to inifiles / letsencrypt dir
if [ -z "${LECONFIGDIR}" ]; then
	LECONFIGDIR="~/.config/letsencrypt"
fi

# Catch missing LECONFIGDIR
if [ ! -d "${LECONFIGDIR}" ]; then
	echo "$0: ${LECONFIGDIR} does not exists! Maybe letsencrypt is not yet initialised!" >&2
	exit 1
fi

# Get all existing inifiles matching namescheme cli-${domain}.ini
for inifile in "${LECONFIGDIR}"/cli-*.ini; do

	# Get domain out of file (first value in property "domains")
	domain=$(grep -e "[ \t]*domains.*" "${inifile}" | sed "s/ //g" |cut -d "=" -f2 | cut -d "," -f1)

	# sleep for a random time so not all certificates get renewed at the same time
	sleep $(expr $RANDOM % 600)

	# Check validity of cert for domain
	openssl x509 -checkend $(( 21 * 86400 )) -in "${LECONFIGDIR}/live/${domain}/cert.pem" > /dev/null

	if [ \$? != 0 ]; then
		# run let's encrypt
		letsencrypt certonly -c "${LECONFIGDIR}/letsencrypt/cli-${domain}.ini"
		# import certificate
		uberspace-add-certificate -k "${LECONFIGDIR}/live/${domain}/privkey.pem" -c "${LECONFIGDIR}/live/${domain}/cert.pem"
	fi

done
