#!/bin/bash

BINDING=`pwd | awk -F/ '{print $NF}'`

if [ -z ${OPENHAB_SETUP_SOURCE} ];
then
        echo "  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "  \$OPENHAB_SETUP_SOURCE not defined"
        echo "  Default wird zur Laufzeit genutzt und auf das aktuelle Verzeichnis gesetzt!"
        echo
        export OPENHAB_SETUP_SOURCE=`pwd`
fi

if [ "$#" -gt "0" ];
then
    DATAPATH=${OPENHAB_SETUP_SOURCE}/$1
else
	DATAPATH=${OPENHAB_SETUP_SOURCE}/${BINDING}
fi

echo "\$1           run in " ${DATAPATH}
echo "\$1           run in " ${OPENHAB_SETUP_SOURCE}
echo "\$1           run in " ${OPENHAB_SETUP_CONF}

cp ${DATAPATH}/mqtt_instar.items ${OPENHAB_SETUP_CONF}/items/.
cp ${DATAPATH}/mqtt_instar.things ${OPENHAB_SETUP_CONF}/things/.
cp ${DATAPATH}/mqtt_instar.map ${OPENHAB_SETUP_CONF}/transform/.
cp ${DATAPATH}/mqtt_instar.sitemap ${OPENHAB_SETUP_CONF}/sitemaps/.
chown -R openhab:openhab  ${OPENHAB_SETUP_CONF}
