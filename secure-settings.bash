#!/bin/bash
#
VERSION=1-0
#
#    AUTHOR         : Ralf Berhorst
#    DATE           : 2022 Juni 04
#
#    PROG.-LANGUAGE : Shell-Skript
#    PROG.-NAME     : secure-settings.bash
#    PROG.-PATH     : ../openhab
#
#    COMPUTER       : a openhab system
#
#    FUNCTION       : remove personal information from your setup
#
#    PARAMETER      : until now - no
#
#######################################################################
#
# ToDo
#
######################################################################

# please configure the env.bash file for your enviroment
. ./env.bash

echo
echo "######################################################################"
echo "Run script "$0
echo
echo "openhab CONF   = "${OPENHAB_SETUP_CONF}
echo "openhab SOURCE = "${OPENHAB_SETUP_SOURCE}
echo "openhab Text   = "${OPENHAB_TEXT_INSTALL}
echo

cd ${OPENHAB_TEXT_INSTALL}
# prepare the target directory
FILE=${OPENHAB_TEXT_INSTALL}/binding-lcn/lcn.things
if [ -f "${FILE}" ]; then 
	echo "replace credentials : "${FILE}
	sed -i 's/OPENHAB/passwort/g' ${FILE}
fi   
FILE=${OPENHAB_TEXT_INSTALL}/binding-avmfritz/avmfritz.things
if [ -f "${FILE}" ]; then 
	echo "replace credentials : "${FILE}
	sed -i 's/OPENHAB!/passwort/g' ${FILE}
fi
FILE=${OPENHAB_TEXT_INSTALL}/binding-openweathermap/openweathermap.things
if [ -f "${FILE}" ]; then 
	echo "replace credentials : "${FILE}
	sed -i 's/OPENHAB/your-api-key/g' ${FILE}
	sed -i 's/50.123456,50,123456,100/50.000000,09.000000,100/g' ${FILE}
fi
FILE=${OPENHAB_TEXT_INSTALL}/binding-astro/astro.things
if [ -f "${FILE}" ]; then 
	echo "replace credentials : "${FILE}
	sed -i 's/50.123456,50,123456,100/50.000000,09.000000,100/g' ${FILE}
fi
FILE=${OPENHAB_TEXT_INSTALL}/binding-tr064/tr064.things
if [ -f "${FILE}" ]; then 
	echo "replace credentials : "${FILE}
	sed -i 's/OPENHAB!/password/g' ${FILE}
fi
FILE=${OPENHAB_TEXT_INSTALL}/binding-mail/mail.things
if [ -f "${FILE}" ]; then 
	echo "replace credentials : "${FILE}
	sed -i 's/smtp.t-online.de/your-smtp-server/g' ${FILE}
	sed -i 's/openhab@dummy.de/your-sender-address/g' ${FILE}
	sed -i 's/openhab@dummy.de/your-user-name/g' ${FILE}
	sed -i 's/xxxxxxxxxxxx/your-password/g' ${FILE}
fi

exit 0
