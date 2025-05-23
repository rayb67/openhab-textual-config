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

cp ${DATAPATH}/_groups.items ${OPENHAB_SETUP_CONF}/items/.
cp ${DATAPATH}/_holiday.script ${OPENHAB_SETUP_CONF}/scripts/.
cp ${DATAPATH}/_holiday.rules ${OPENHAB_SETUP_CONF}/rules/.
chown -R openhab:openhab  ${OPENHAB_SETUP_CONF}
