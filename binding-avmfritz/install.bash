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

#cp ${DATAPATH}/avm*.map $OPENHAB_SETUP_CONF/transform/.
cp ${DATAPATH}/avm*.rules $OPENHAB_SETUP_CONF/rules/.
cp ${DATAPATH}/avm*.items $OPENHAB_SETUP_CONF/items/.
cp ${DATAPATH}/avm*.sitemap $OPENHAB_SETUP_CONF/sitemaps/.
cp ${DATAPATH}/avm*.things $OPENHAB_SETUP_CONF/things/.
chown -R ${OPENHAB_USER}:${OPENHAB_GROUP}  ${OPENHAB_SETUP_CONF}
