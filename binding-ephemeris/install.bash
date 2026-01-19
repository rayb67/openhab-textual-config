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

cp ${DATAPATH}/ephemeris.things ${OPENHAB_SETUP_CONF}/things/.
cp ${DATAPATH}/ephemeris.items ${OPENHAB_SETUP_CONF}/items/.
cp ${DATAPATH}/ephemeris.sitemap ${OPENHAB_SETUP_CONF}/sitemaps/.
cp ${DATAPATH}/ephemeris.rules ${OPENHAB_SETUP_CONF}/rules/.
cp ${DATAPATH}/ephemeris.cfg ${OPENHAB_SETUP_CONF}/services/.
mkdir ${OPENHAB_SETUP_CONF}/misc
mkdir ${OPENHAB_SETUP_CONF}/misc/ephemeris
cp ${DATAPATH}/ephemeris.xml ${OPENHAB_SETUP_CONF}/misc/ephemeris/.
cp ${DATAPATH}/MyEntry_de.xml ${OPENHAB_SETUP_CONF}/misc/ephemeris/.
cp ${DATAPATH}/Holidays_de.xml ${OPENHAB_SETUP_CONF}/misc/ephemeris/.

chown -R openhab:openhab  ${OPENHAB_SETUP_CONF}
