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

cp ${DATAPATH}/_groups.items ${OPENHAB_SETUP_CONF}/items/.
cp ${DATAPATH}/_oh.items ${OPENHAB_SETUP_CONF}/items/.
cp ${DATAPATH}/_holiday.script ${OPENHAB_SETUP_CONF}/scripts/.
cp ${DATAPATH}/_holiday.rules ${OPENHAB_SETUP_CONF}/rules/.
chown -R openhab:openhab  ${OPENHAB_SETUP_CONF}
