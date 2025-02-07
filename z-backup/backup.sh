#!/bin/sh
#
#    Version          : V1.2
#
#    AUTOR            : R. Berhorst
#    DATUM            : 01.07.2016
#
#    PROG.-SPRACHE    : Shell-Skript
#    PROG.-NAME       : 2-backup.sh
#    PROG.-PFAD       : /usr/local/bin
#    RECHNER          : beliebig
#
#    FUNKTION         : 
#
#    PARAMETER        : none
#
#######################################################################
# http://linuxwiki.de/rsync/SnapshotBackups
#######################################################################
#
# Darueber hinaus kann man ein Image erstellen/ verkleinern und 
#
# https://techgeeks.de/raspberry-pi-image-installieren-backup-und-verkleinern/
#
# sudo dd bs=4M if=/dev/mmcblk0 of=/nas/linux/image-backup/`hostname`-`date '+%F-%H%M'`.img status=progress
#
#######################################################################

echo 
echo "#######################################################################"
echo
date
echo

HOST=`hostname`

BACKUPFOLDER=`cat /usr/local/bin/backup.conf`
BACKUPPATH=/nas/linux/backups/`hostname`.fritz.box
BACKUPFILE=backup-file-`hostname`-`date +%Y%m%d-%H%M%S`.tgz

INCL=`cat /usr/local/bin/backup.conf`
EXCL="--exclude=*.pid \
	--exclude=*.lck \
	--exclude=/docker/openhab/data/userdata/tmp/* \
	--exclude=/docker/openhab/data/userdata/backup/* \
	--exclude=/docker/openhab/data/userdata/cache/* \
	--exclude=/docker/openhab/data_mariadb/* \
	--exclude=/var/lib/docker/overlay2/*"

## use this command line to have it working properly.
RSYNC="/usr/bin/rsync --rsync-path=/usr/bin/rsync"

echo "Starting backup for $HOST"

# Backup all regular files.
echo "----------------------"
# echo ${RSYNC}
echo "exclude : " ${EXCL}
echo "host    : " $HOST
echo "include : " ${INCL} 
# echo ${BACKUPS}
echo "----------------------"
cd /
${RSYNC} --inplace -delete -aRHh ${EXCL} ${INCL} ${BACKUPPATH}

echo "Finished backup for $HOST."

echo
date
echo
exit 0
