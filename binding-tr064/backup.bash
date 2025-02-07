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

cd ${DATAPATH}

cp ${OPENHAB_SETUP_CONF}/things/tr064.things .
cp ${OPENHAB_SETUP_CONF}/items/tr064.items .
#cp ${OPENHAB_SETUP_CONF}/rules/tr064.rules .
cp ${OPENHAB_SETUP_CONF}/transform/tr064.map .
#cp ${OPENHAB_SETUP_CONF}/sitemaps/tr064.sitemap .
