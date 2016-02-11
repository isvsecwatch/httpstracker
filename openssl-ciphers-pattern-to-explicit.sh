#!/bin/bash
#
# Converts a cipher selection pattern into a list of explicitly defined
# ciphers, as recommended by the Mozilla server-side configuration.
#

CIPHERS="${1}"
[ 'x${CIPHERS}' == 'x' ] && exit 1

openssl ciphers -v "${CIPHERS}" | awk '{ print $1 }' \
	| tr '\n' ':' | sed 's/:$/\n/'
