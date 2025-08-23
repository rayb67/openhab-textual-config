#!/bin/bash
# Some general environment infomration.
# The version must match exactly!

export OPENHAB_VERSION=4.3.5
export JDK_VERSION=17  # Java 17 for OH 4.x ; Java 21 for OH 5.x
export OPENHAB_USER=openhab
export OPENHAB_GROUP=openhab
export OPENHAB_DBNAME=openhab
export OPENHAB_DBPASSWD=openhab
export CUSTOM_BIN=/usr/local/bin
export OPENHAB_SETUP_FILES=openhab-setup-step-files-$VERSION

# important to know in case of restore, what is the source (PRD) and what is the target (DEV)
# Some parameter must change and/or cleand up
export OPENHAB_PRD_HOSTNAME=server-prd
export OPENHAB_PRD_IP=10.10.10.68
export OPENHAB_DEV_HOSTNAME=server-dev
export OPENHAB_DEV_IP=10.10.10.125
export OPENHAB_RESTORE=/tmp/openhab-restore
export OPENHAB_LOGPATH=/var/log/openhab
export BACKUP_PATH=/nas/linux/backups

# this is my production server
if [ `hostname` == "server-prd" ];
then
    echo "  env.bash - hostname server-prd"
    export OPENHAB_DB_BASE=/volume4/@appstore/MariaDB10/mysql
    export OPENHAB_DOCKER_BASE=/volume4/docker
	export OPENHAB_SRV_TYPE=prd
    export OPENHAB_DOCKER=true
    export OPENHAB_SETUP_CONF=${OPENHAB_DOCKER_BASE}/openhab/conf
    export OPENHAB_SETUP_USERDATA=${OPENHAB_DOCKER_BASE}/openhab/userdata
    export OPENHAB_SETUP_ADDONS=${OPENHAB_DOCKER_BASE}/openhab/addons
    export OPENHAB_SETUP_SOURCE=/volume1/default/linux/install/openhab
    export OPENHAB_LOGPATH=${OPENHAB_SETUP_USERDATA}/logs
fi

# this is my develpment server
if [ `hostname` == "server-dev" ];
then
    echo "  env.bash - hostname server-dev"
    export OPENHAB_DB_BASE=/docker/openhab/data_mariadb
    export OPENHAB_DOCKER_BASE=/docker/openhab
	export OPENHAB_SRV_TYPE=dev
    export OPENHAB_DOCKER=true
    export OPENHAB_SETUP_CONF=${OPENHAB_DOCKER_BASE}/data/conf
    export OPENHAB_SETUP_USERDATA=${OPENHAB_DOCKER_BASE}/data/userdata
    export OPENHAB_SETUP_ADDONS=${OPENHAB_DOCKER_BASE}/data/addons
    export OPENHAB_LOGPATH=${OPENHAB_SETUP_USERDATA}/logs
fi

# this is my sandbox server
if [ `hostname` == "mac-ubuntu" ];
then
    echo "  env.bash - hostname mac-ubuntu"
	export OPENHAB_SRV_TYPE=sbx
fi

if [ -z ${OPENHAB_SETUP_CONF} ];
then
    echo "  env.bash -  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  env.bash -  \$OPENHAB_SETUP_CONF not defined"
    echo "  env.bash -  Default wird zur Laufzeit genutzt!"
    echo
    export OPENHAB_SETUP_CONF=/etc/openhab
fi

if [ -z ${OPENHAB_SETUP_USERDATA} ];
then
        echo "  env.bash -  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "  env.bash -  \$OPENHAB_SETUP_USERDATA not defined"
        echo "  env.bash -  Default wird zur Laufzeit genutzt!"
        echo
        export OPENHAB_SETUP_CONF=/usr/share/openhab/userdata
fi

if [ -z ${OPENHAB_SETUP_SOURCE} ];
then
        echo "  env.bash -  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "  env.bash -  \$OPENHAB_SETUP_SOURCE not defined"
        echo "  env.bash -  Default wird zur Laufzeit genutzt und auf das aktuelle Verzeichnis gesetzt!"
        echo
        export OPENHAB_SETUP_SOURCE=`pwd`
fi

if [ "$OPENHAB_DOCKER" == "true" ];
then
        echo "  env.bash - Docker is : "$OPENHAB_DOCKER
else
        echo "  env.bash - no Docker installation "$OPENHAB_DOCKER
fi


if [ -z ${OPENHAB_SETUP_CONF} ];
then
        echo "  env.bash -  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "  env.bash -  \$OPENHAB_SETUP_CONF not defined"
        echo "  env.bash -  Default wird zur Laufzeit genutzt!"
        echo
        export OPENHAB_SETUP_CONF=/etc/openhab
fi

if [ -z ${OPENHAB_SETUP_USERDATA} ];
then
        echo "  env.bash -  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "  env.bash -  \$OPENHAB_SETUP_USERDATA not defined"
        echo "  env.bash -  Default wird zur Laufzeit genutzt!"
        echo
        export OPENHAB_SETUP_CONF=/usr/share/openhab/userdata
fi

if [ -z ${OPENHAB_SETUP_SOURCE} ];
then
        echo "  env.bash -  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "  env.bash -  \$OPENHAB_SETUP_SOURCE not defined"
        echo "  env.bash -  Default wird zur Laufzeit genutzt und auf das aktuelle Verzeichnis gesetzt!"
        echo
        export OPENHAB_SETUP_SOURCE=`pwd`
fi

