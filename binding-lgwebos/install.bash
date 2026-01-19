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

cp ${DATAPATH}/lgwebos*.rules $OPENHAB_SETUP_CONF/rules/.
cp ${DATAPATH}/lgwebos*.items $OPENHAB_SETUP_CONF/items/.
cp ${DATAPATH}/lgwebos*.sitemap $OPENHAB_SETUP_CONF/sitemaps/.
cp ${DATAPATH}/lgwebos*.things $OPENHAB_SETUP_CONF/things/.
#chown -R ${OPENHAB_USER}:${OPENHAB_GROUP}  ${OPENHAB_SETUP_CONF}
