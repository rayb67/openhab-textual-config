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

#echo "\$1           run in " ${DATAPATH}
#echo "\$1           run in " ${OPENHAB_SETUP_SOURCE}
#echo "\$1           run in " ${OPENHAB_SETUP_CONF}

cp ${DATAPATH}/modbusstiebel.items $OPENHAB_SETUP_CONF/items/.
cp ${DATAPATH}/modbusstiebel.things $OPENHAB_SETUP_CONF/things/.
cp ${DATAPATH}/*.map $OPENHAB_SETUP_CONF/transform/.
cp ${DATAPATH}/modbusstiebel_*.rules $OPENHAB_SETUP_CONF/rules/.
cp ${DATAPATH}/modbusstiebel.sitemap $OPENHAB_SETUP_CONF/sitemaps/.
sudo chown -R ${OPENHAB_GROUP}:${OPENHAB_USER}  ${OPENHAB_SETUP_CONF}
