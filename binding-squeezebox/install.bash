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
    DATAPATH=${OPENHAB_SETUP_SOURCE}/$1
else
    DATAPATH=${OPENHAB_SETUP_SOURCE}/${BINDING}
fi

#echo "\$1           run in " ${DATAPATH}
#echo "\$1           run in " ${OPENHAB_SETUP_SOURCE}
#echo "\$1           run in " ${OPENHAB_SETUP_CONF}

cp ${DATAPATH}/squeezebox.items $OPENHAB_SETUP_CONF/items/.
cp ${DATAPATH}/squeezebox.sitemap $OPENHAB_SETUP_CONF/sitemaps/.
cp ${DATAPATH}/squeezebox.things $OPENHAB_SETUP_CONF/things/.
cp ${DATAPATH}/squeezebox.rules $OPENHAB_SETUP_CONF/rules/.
cp ${DATAPATH}/squeezebox_time.js $OPENHAB_SETUP_CONF/transform/.
