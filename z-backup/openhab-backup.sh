#!/bin/bash
#
#    Version          : V1.5
#
#    AUTOR            : R. Berhorst
#    DATUM            : 2024.08.10
#
#    PROG.-SPRACHE    : Shell-Skript
#    PROG.-NAME       : openhab-backup.sh
#    PROG.-PFAD       : /usr/local/bin
#    RECHNER          : ???.fritz.box 
#
#    FUNKTION         : 
## This script does a backup for openhab data
#
#    PARAMETER        : none
#
#######################################################################
#
#   If you like to import the file, use the followin command
#   mysql -u root -p openhab < openhab-export-db-20111207-1714.sql
#
#######################################################################
##
## 2011.12.06
## V1.0  initial setup
##
## 2012.06.07
## v1.1  Passworte modifiziert
##
## 2012.06.09
## v1.2  exit vor der letzten Ausgabe beseitigt
##
## 2016.07.28
## v1.3  umstellung auf openhab
##
## 2021.12.29
## v1.4  DB Name Parameter ergaenst weil OH 3 eine neue DB hat
##
## 2024.08.10
## v1.5  Umstellung auf docker
##
#######################################################################
##
ServerProd=server-prd
ServerBack=server-dev

ServerCurrent=`hostname -s`

#OpenhabProd=/etc/openhab
OpenhabProd=${OPENHAB_SETUP_CONF}
CurrentDATE=`date +%Y%m%d-%H%M`

OPENHABDB=openhab
BACKUPPATH=/nas/linux/backups/${ServerCurrent}.fritz.box
BACKUPDB=openhab-db-`hostname`-${CurrentDATE}.sql
BACKUPFILE=openhab-file-`hostname`-${CurrentDATE}.tgz
OPENHABDBUSER=openhab
OPENHABDBPW=openhab

echo "#########################################################"
echo
echo "start run on    : "${ServerCurrent}
echo "current time    : "`date`
echo "backuppath      : "${BACKUPPATH} 
echo "backupfile      : "${BACKUPFILE}
echo "OpenhabProd      : "${OpenhabProd}
echo

if [ ${ServerCurrent} = ${ServerProd} ]; then
	echo "Prod >"
#	/usr/bin/mysqldump -h 127.0.0.1 -u ${OPENHABDBUSER} -p${OPENHABDBPW} ${OPENHABDB} > ${BACKUPPATH}/${BACKUPDB}
	/usr/bin/mysqldump -h 127.0.0.1 -u openhab -popenhab ${OPENHABDB} > ${BACKUPPATH}/${BACKUPDB}
	/usr/bin/mysqldump -h 127.0.0.1 -u openhab -popenhab analyse > ${BACKUPPATH}/openhab-db-analyse-${CurrentDATE}.sql
#	gzip ${BACKUPPATH}/*.sql

#	/usr/share/openhab/runtime/bin/backup  ${BACKUPPATH}/openhab-${CurrentDATE}.zip
	docker exec -it openhab-openhab runtime/bin/backup userdata/dummy.zip
	mv /docker/openhab4/data/userdata/dummy.zip ${BACKUPPATH}/openhab-backup-${CurrentDATE}.zip

#   das folgende ist doppelt, solange der nativ openhab backup befehlt funktioniert
#   auch fehlen beim tar die Dateien aus dem userdata  .... verzeichnis
#	cd ${OpenhabProd}
#	tar cfz ${BACKUPPATH}/${BACKUPFILE} *

elif [ ${ServerCurrent} = ${ServerBack} ]; then
	echo "Back >"
#	scp ${ServerProd}:/daten/${ServerProd}/openhab-${ServerProd}.tgz /daten/${ServerProd}/.
	cd /etc/openhab-${ServerProd}
	tar xfz /daten/${ServerProd}/openhab-${ServerProd}.tgz
	rm /daten/${ServerProd}/openhab-files-current.tgz
	ln -s ${BACKUPPATH}/${BACKUPFILE} /daten/${ServerProd}/openhab-files-current.tgz

	# imporant are the rrd files too
# 	/usr/bin/rsync --rsync-path=/usr/bin/rsync -avHr --inplace ${ServerProd}:/var/icinga/rrd/* /var/icinga/rrd/ > /dev/null

elif [ ${ServerCurrent} = ${ServerDev} ]; then
	echo "Dev >"
else
	echo "Error - script is not set to run on this host!"
fi

echo
echo "end run on      : "${ServerCurrent}
echo "current time    : "`date`
echo
