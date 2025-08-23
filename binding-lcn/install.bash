#!/bin/bash

BINDING=`pwd | awk -F/ '{print $NF}'`

if [ -z ${OPENHAB_SETUP_SOURCE} ];
then
        echo "  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "  \$OPENHAB_SETUP_SOURCE not defined"
        echo "  ...please set e.g.:"
        echo "  export OPENHAB_SETUP_SOURCE=/dsnas/install/openhab"
        exit
fi

if [ "$#" -gt "0" ];
then
    DATAPATH=$OPENHAB_SETUP_SOURCE/$1
else
	DATAPATH=${OPENHAB_SETUP_SOURCE}/${BINDING}
fi

FILE=$DATAPATH
if [ ! -d $FILE  ]; then
    echo "Wrong call because folder does not exist : "$FILE
    exit
fi

cp ${DATAPATH}/lcn*.items ${OPENHAB_SETUP_CONF}/items/.
cp ${DATAPATH}/lcn*.sitemap ${OPENHAB_SETUP_CONF}/sitemaps/.
cp ${DATAPATH}/lcn.things ${OPENHAB_SETUP_CONF}/things/.
cp ${DATAPATH}/lcn_*.rules ${OPENHAB_SETUP_CONF}/rules/.
cp ${DATAPATH}/lcn.map ${OPENHAB_SETUP_CONF}/transform/.
chown -R openhab:openhab  ${OPENHAB_SETUP_CONF}
