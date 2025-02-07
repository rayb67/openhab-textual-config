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


cp ${OPENHAB_SETUP_CONF}/things/modbus*.things .
cp ${OPENHAB_SETUP_CONF}/items/modbus*.items .
#cp ${OPENHAB_SETUP_CONF}/rules/modbus*.rules .
cp ${OPENHAB_SETUP_CONF}/transform/modbus*.map .
cp ${OPENHAB_SETUP_CONF}/sitemaps/modbus*.sitemap .
cp ${OPENHAB_SETUP_CONF}/transform/boolean.map .
