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

cp ${DATAPATH}/comfoair*.map $OPENHAB_SETUP_CONF/transform/.
cp ${DATAPATH}/comfoair.items $OPENHAB_SETUP_CONF/items/.
cp ${DATAPATH}/comfoair.sitemap $OPENHAB_SETUP_CONF/sitemaps/.
cp ${DATAPATH}/comfoair.things $OPENHAB_SETUP_CONF/things/.
cp ${DATAPATH}/comfoair*.rules $OPENHAB_SETUP_CONF/rules/.
chown -R openhab:openhab  ${OPENHAB_SETUP_CONF}
