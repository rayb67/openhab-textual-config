#!/bin/bash

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
    echo "not possible without parameter!"
    echo "parameter set e.g.: binding-<name>"
    exit
fi

FILE=$DATAPATH
if [ ! -d $FILE  ]; then
    echo "Wrong call because folder does not exist : "$FILE
    exit
fi

cp ${DATAPATH}/modbusstiebel.items $OPENHAB_SETUP_CONF/items/.
cp ${DATAPATH}/modbusstiebel.things $OPENHAB_SETUP_CONF/things/.
cp ${DATAPATH}/modbusstiebel_*.map $OPENHAB_SETUP_CONF/transform/.
cp ${DATAPATH}/modbusstiebel_*.rules $OPENHAB_SETUP_CONF/rules/.
cp ${DATAPATH}/modbusstiebel.sitemap $OPENHAB_SETUP_CONF/sitemaps/.
chown -R openhab:openhab  ${OPENHAB_SETUP_CONF}
