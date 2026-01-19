#!/bin/bash

BINDING=`pwd | awk -F/ '{print $NF}'`

if [ -z ${OPENHAB_SETUP_SOURCE} ];
then
        echo "  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "  \$OPENHAB_SETUP_SOURCE not defined"
        echo "  Default wird zur Laufzeit genutzt und auf das aktuelle Verzeichnis gesetzt!"
        echo
        export OPENHAB_SETUP_SOURCE=`pwd`
        exit
fi

if [ "$#" -gt "0" ];
then
    DATAPATH=$OPENHAB_SETUP_SOURCE/$1
else
	DATAPATH=${OPENHAB_SETUP_SOURCE}/${BINDING}
fi

#echo "conf  >"${OPENHAB_SETUP_CONF}"<"
#echo "sourc >"${OPENHAB_SETUP_SOURCE}"<"
#echo "daat  >"${DATAPATH}"<"

cp ${DATAPATH}/openweathermap*.map $OPENHAB_SETUP_CONF/transform/.
cp ${DATAPATH}/openweathermap.items $OPENHAB_SETUP_CONF/items/.
#cp ${DATAPATH}/openweathermap.rules $OPENHAB_SETUP_CONF/rules/.
cp ${DATAPATH}/openweathermap.sitemap $OPENHAB_SETUP_CONF/sitemaps/.
cp ${DATAPATH}/openweathermap*.things $OPENHAB_SETUP_CONF/things/.
chown -R openhab:openhab  ${OPENHAB_SETUP_CONF}
