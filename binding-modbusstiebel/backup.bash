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

FILE=$DATAPATH
if [ ! -d $FILE  ]; then
    echo "Wrong call because folder does not exist : "$FILE
    exit
fi

cd ${DATAPATH}


cp ${OPENHAB_SETUP_CONF}/things/modbusstiebel.things .
cp ${OPENHAB_SETUP_CONF}/items/modbusstiebel.items .
cp ${OPENHAB_SETUP_CONF}/rules/modbusstiebel*.rules .
cp ${OPENHAB_SETUP_CONF}/transform/modbusstiebel*.map .
cp ${OPENHAB_SETUP_CONF}/transform/bool*.map .
cp ${OPENHAB_SETUP_CONF}/sitemaps/modbusstiebel.sitemap .
cp ${OPENHAB_SETUP_CONF}/transform/boolean.map .
