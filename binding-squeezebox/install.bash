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

cp ${DATAPATH}/squeezebox.items $OPENHAB_SETUP_CONF/items/.
cp ${DATAPATH}/squeezebox.sitemap $OPENHAB_SETUP_CONF/sitemaps/.
cp ${DATAPATH}/squeezebox.things $OPENHAB_SETUP_CONF/things/.
cp ${DATAPATH}/squeezebox.rules $OPENHAB_SETUP_CONF/rules/.
cp ${DATAPATH}/squeezebox_time.js $OPENHAB_SETUP_CONF/transform/.
