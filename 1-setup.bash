#!/bin/bash
#
VERSION=0-4
#
#    AUTHOR         : Ralf Berhorst
#    DATE           : 2022 Jun 06
#
#    PROG.-LANGUAGE : Shell-Script
#    PROG.-NAME     : 1-setup.bash
#    PROG.-PATH     : ?
#
#    COMPUTER       : openhab server
#
#    FUNCTION       : try to install openhab with some basic settings
#                     furthermore some additional add-ons
#
#    PARAMETER      : some... thy without a parameter
#
#######################################################################
# Additional information available here :
# https://www.openhab.org/docs/configuration/#textual-vs-graphical-configuration
#
# 2024.05.12 detect docker
#
# 2025.01.04 optimize docker installation
#
# 2025.02.06 check and optimize code redundances
######################################################################
#
# all possible bindings are exists as folder
# binding-NAME where NAME ist the binding name.
# e.g. astro binding - Name must be "binding-astro"
# keep in mind, this script can run only in the folder where all the openhab sources are
BINDING_SOURCE=`ls | grep binding | cut -d- -f2- | sort`

clear

#####################################################################
# Some environment checks und configuration belongs to the machine
# All variables are located in env.bash or /etc/profile
#####################################################################
. ./env.bash

#####################################################################
init-check_installed_bindings() {
	
	BINDING_INSTALLED=`cd $OPENHAB_SETUP_CONF/items ; ls *items | cut -d. -f-1 | grep -v groups | grep -v lcnSunPro | sort`
	echo "## I detect these bindings because of the items : "
	echo $BINDING_INSTALLED
	echo

	return $RETVAL
}

#######################################################################
#######################################################################

OPENHAB_LOCATION=`grep astro:sun:local ${OPENHAB_SETUP_SOURCE}/binding-astro/astro.things | cut -d'"' -f 4`
umask 022

function error {
	echo "error in script : >"$0"<"
	exit
}


#######################################################################
#######################################################################
inst-base() {

	function-check-prod  # if the current system is PRD, we stop

	if [ "$OPENHAB_DOCKER" == "true" ];
	then
		echo "Docker was set - do not install local software"
		return $RETVAL
	fi

	cd $OPENHAB_SETUP_SOURCE

	groupadd ${OPENHAB_GROUP}
	useradd -g ${OPENHAB_GROUP} -d ${OPENHAB_SETUP_USERDATA} -c "openhab admin" ${OPENHAB_USER}

	FILE=/etc/apt/sources.list.d/openhab.list
	if [ -f $FILE  ]; then
		echo "APT is configured: "$FILE
	else
		apt install apt-transport-https -y
		echo 'deb [signed-by=/usr/share/keyrings/openhab.gpg] https://openhab.jfrog.io/artifactory/openhab-linuxpkg stable main' | sudo tee /etc/apt/sources.list.d/openhab.list
	fi

	apt install -y curl gpg

	FILE=/usr/share/keyrings/openhab.gpg
	if [ -f $FILE  ]; then
		echo "Keyfile exsist: "$FILE
	else
		cd /usr/share/keyrings
		curl -fsSL "https://openhab.jfrog.io/artifactory/api/gpg/key/public" | gpg --dearmor > openhab.gpg
		sudo chmod u=rw,g=r,o=r /usr/share/keyrings/openhab.gpg
	fi

	apt-get update
	apt upgrade -y
	apt install git -y
	apt install openjdk-${JDK_VERSION}-jre -y

	## because of networking binding
    apt-get install iputils-arping -y
  
	return $RETVAL
}


#######################################################################
#######################################################################
remove() {

	function-check-prod  # if the current system is PRD, we stop

    if [ "${OPENHAB_DOCKER}" == "true" ];
	then 
		echo "The openhab container will be removed and craeted again."

		cd ${OPENHAB_DOCKER_BASE}
		pwd
		echo "stop"
 		docker stop openhab
		echo "rm"
 		docker rm openhab
		echo "rm"
 		rm -R data/*

		return $RETVAL
	fi

	while true; do
		read -p "Are you really sure to remove the openhab installation ??? " yn
		case $yn in
		[Yy]* ) 
			echo; echo "now we remove !"; echo "stop openhab if it is running"
			sudo systemctrl stop openhab.service
			echo; echo "purge openhab (uninstall and remove foldes )"; echo
			apt purge openhab -y
			echo; echo "remove openhab-addons"; echo
			apt remove openhab openhab-addons -y
			break;;
		[Nn]* ) 
			exit
			;;
		* ) 
			echo ; echo "Please answer yes or no."; echo 
			;;
		 esac
	done
		
	return $RETVAL
}



#######################################################################
#######################################################################
inst-db() {

   cp ${OPENHAB_SETUP_SOURCE}/default/jdbc.cfg  ${OPENHAB_SETUP_CONF}/services/.
   cp ${OPENHAB_SETUP_SOURCE}/default/jdbc.persist  ${OPENHAB_SETUP_CONF}/persistence/.
   chown -R openhab:openhab ${OPENHAB_SETUP_CONF}

   cp default/mariadb-java-client-3.0.8.jar ${OPENHAB_SETUP_ADDONS}
   chown openhab:openhab ${OPENHAB_SETUP_ADDONS}/*
        
	if [ "$OPENHAB_DOCKER" == "true" ];
	then
		echo "Docker was set - do not install maria-db"
		return $RETVAL
	fi

	## configure Database mariaDB
	apt-get install mariadb-server phpmyadmin libapache2-mod-php php-cli php-mysql php-zip php-curl php-xml php-mbstring php-zip php-gd unzip -y
	ln -sf /usr/share/zoneinfo/Etc/UTC  /etc/localtime

	echo
	echo "   !!!! Think about to MySQL Secure Installation if you finished !!!"
	echo "   Run MySQL Secure Installation with following command:"
	echo "   mysql_secure_installation "
	echo
	read -p "   push >Enter< to go on  "

	if [ -d "/var/lib/mysql/${OPENHAB_DBNAME}" ] 
	then
		echo "DB exist - check that"

		while true; do
			read -p "Are you shure to remove the database ? " yn
			case $yn in
			[Yy]* ) echo "we go on"; break;;
			[Nn]* ) return $RETVAL;;
			* ) echo "Please answer yes or no.";;
			 esac
		done
		echo "We drop the database : ${OPENHAB_DBNAME} "
		echo
		echo "type in the root password !!!"
		echo
mysql -u root -p << 'EndOfDBCreate'
DROP database openhab;
DROP USER 'openhab'@'localhost';
DROP USER 'openhab'@'172.%.%.%';
DROP USER 'openhab'@'192.168.%.%';
DROP USER 'pma'@'localhost';
DROP USER 'pma'@'172.%.%.%';
DROP USER 'pma'@'192.168.%.%';
FLUSH PRIVILEGES;
quit
EndOfDBCreate

		# sql query to check GRANTS
		# SHOW GRANTS FOR 'openhab'@'localhost';
	else
	    echo "Database does not exist does not exists."
	fi


	echo
	echo "type in the root password !!!"
	echo
#################################
# MySQL DB setup
#  mysql -u root -p
# create the database automatically
# grand access for openhab and phpmyadmin too.
# phpmyadmin user is "pma" with password "password"
mysql -u root -p << 'EndOfDBCreate'
CREATE DATABASE openhab;
CREATE USER 'openhab'@'localhost' IDENTIFIED BY 'openhab';
CREATE USER 'openhab'@'172.%.%.%' IDENTIFIED BY 'openhab';
CREATE USER 'openhab'@'192.168.%.%' IDENTIFIED BY 'openhab';
CREATE USER 'pma'@'172.%.%.%' IDENTIFIED BY 'password';
CREATE USER 'pma'@'192.168.%.%' IDENTIFIED BY 'password';
CREATE USER 'pma'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON openhab.* TO 'openhab'@'localhost';
GRANT ALL PRIVILEGES ON openhab.* TO 'openhab'@'192.186.%.%';
GRANT ALL PRIVILEGES ON openhab.* TO 'openhab'@'172.%.%.%';
GRANT ALL PRIVILEGES ON *.* TO 'pma'@'172.%.%.%';
GRANT ALL PRIVILEGES ON *.* TO 'pma'@'192.168.%.%';
GRANT ALL PRIVILEGES ON *.* TO 'pma'@'localhost';
FLUSH PRIVILEGES;
quit
EndOfDBCreate

	return $RETVAL
}

#######################################################################
#######################################################################
docker-reset() {

	echo 
	echo "Docker Reset"
	echo 
	echo "... The openhab container will be removed and craeted again."

	function-openhab-stop

    if [ "${OPENHAB_DOCKER}" == "true" ];
	then 

		cd ${OPENHAB_DOCKER_BASE}
		echo "... rm openhab"
 		docker rm openhab
		echo "... rm data"
 		rm -R data/*
		echo "... start new container"
 		docker compose up -d
		echo "... wait must 1-2 Minutes until openhab is ready ..."

		sleep 10 
	fi

	function-openhab-check-running

	return $RETVAL
}


#######################################################################
#######################################################################
function-check-prod() {

	if [ `hostname` == "${OPENHAB_PRD_HOSTNAME}" ];
	then
		echo
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "PROD System - we will not install defaults ;-)"	
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo
		exit
	fi

	return $RETVAL
}

#######################################################################
#######################################################################
docker-default() {

	function-check-prod  # if the current system is PRD, we stop

	FILE=${OPENHAB_LOGPATH}/openhab.log

	echo "openhab startup is running... we wait..."
	while true; do
		START_STATUS=`grep RuleEngineImpl ${FILE}`

		if [ -z "$START_STATUS" ]; then
			echo "...still waiting..."
		else
			echo "now openhab stopping..."
			docker stop openhab
			echo "copy defautls"

			inst-defaults

			# todo - fist check if data from a dev installation is available
			# 
			if [ `hostname` == "${OPENHAB_DEV_HOSTNAME}" ];
			then
				echo "oook"
				cp ${OPENHAB_SETUP_SOURCE}/defaults/uuid.`hostname` ${OPENHAB_SETUP_USERDATA}/uuid
				mkdir ${OPENHAB_SETUP_USERDATA}/openhabcloud
				cp ${OPENHAB_SETUP_SOURCE}/defaults/secret.`hostname` ${OPENHAB_SETUP_USERDATA}/openhabcloud/secret
				chown -R openhab:openhab ${OPENHAB_SETUP_USERDATA}
				chown -R openhab:openhab ${OPENHAB_SETUP_CONF}
			else
				echo "!!!!!!!!!!!!1"
				echo "Prod System - not install"
				echo "!!!!!!!!!!!!1"
				exit
			fi

			echo
			echo " user     : admin"
			echo " password : admin"
			echo

			sleep 5
			rm ${FILE}

			echo "openhab starting!"
#			docker start openhab
#			function-openhab-check-running
			return $RETVAL
		fi

		sleep 5
	done

	return $RETVAL
}
 

#######################################################################
inst-example() {

	function-check-prod  # if the current system is PRD, we stop

	function-openhab-stop   ## call funtion

	cp ${OPENHAB_SETUP_SOURCE}/example/users.json ${OPENHAB_SETUP_USERDATA}/jsondb/.
	cp ${OPENHAB_SETUP_SOURCE}/example/users.properties ${OPENHAB_SETUP_USERDATA}/etc/.
	cp ${OPENHAB_SETUP_SOURCE}/example/addons.cfg  ${OPENHAB_SETUP_CONF}/services/.
	cp ${OPENHAB_SETUP_SOURCE}/example/default.sitemap ${OPENHAB_SETUP_CONF}/sitemaps/.
	cp ${OPENHAB_SETUP_SOURCE}/example/rrd4j.cfg  ${OPENHAB_SETUP_CONF}/services/.
	cp ${OPENHAB_SETUP_SOURCE}/example/rrd4j.persist  ${OPENHAB_SETUP_CONF}/persistence/.
	cp ${OPENHAB_SETUP_SOURCE}/example/jdbc.cfg  ${OPENHAB_SETUP_CONF}/services/.
	cp ${OPENHAB_SETUP_SOURCE}/example/jdbc.persist  ${OPENHAB_SETUP_CONF}/persistence/.
	cp ${OPENHAB_SETUP_SOURCE}/example/*.map  ${OPENHAB_SETUP_CONF}/transform/.

	mkdir ${OPENHAB_SETUP_CONF}/html/floorplans
	cp -r ${OPENHAB_SETUP_SOURCE}/images/floorplans/* ${OPENHAB_SETUP_CONF}/html/floorplans
	cp -r ${OPENHAB_SETUP_SOURCE}/images/classic/* ${OPENHAB_SETUP_CONF}/icons/classic

	chown -R openhab:openhab ${OPENHAB_SETUP_CONF}
	chown -R openhab:openhab ${OPENHAB_SETUP_USERDATA}

	export BINDING_SELECT="astro systeminfo openweathermap ephemeris"
	inst-select
	
	echo 
	echo "user : admin    password : admin"
	echo 
	echo
	function-openhab-start   ## call funtion

	return $RETVAL
}


#######################################################################
inst-default() {

	function-check-prod  # if the current system is PRD, we stop

	function-openhab-start   ## call funtion

	cp ${OPENHAB_SETUP_SOURCE}/defaults/i18n.config ${OPENHAB_SETUP_USERDATA}/config/org/openhab/.
	cp ${OPENHAB_SETUP_SOURCE}/defaults/users.json ${OPENHAB_SETUP_USERDATA}/jsondb/.
	cp ${OPENHAB_SETUP_SOURCE}/defaults/users.properties ${OPENHAB_SETUP_USERDATA}/etc/.
	cp ${OPENHAB_SETUP_SOURCE}/defaults/addons.cfg ${OPENHAB_SETUP_CONF}/services/.

	cp ${OPENHAB_SETUP_SOURCE}/config-prod/default.sitemap ${OPENHAB_SETUP_CONF}/sitemaps/.
	cp ${OPENHAB_SETUP_SOURCE}/config-prod/rrd4j.cfg  ${OPENHAB_SETUP_CONF}/services/.
	cp ${OPENHAB_SETUP_SOURCE}/config-prod/rrd4j.persist  ${OPENHAB_SETUP_CONF}/persistence/.
	cp ${OPENHAB_SETUP_SOURCE}/config-prod/_group.items  ${OPENHAB_SETUP_CONF}/items/.
	cp ${OPENHAB_SETUP_SOURCE}/config-prod/boolean.map  ${OPENHAB_SETUP_CONF}/transform/.
	cp ${OPENHAB_SETUP_SOURCE}/config-prod/uicomponents_habpanel_panelconfig.json ${OPENHAB_SETUP_USERDATA}/jsondb/.
	cp ${OPENHAB_SETUP_SOURCE}/config-prod/uicomponents_ui_*.json ${OPENHAB_SETUP_USERDATA}/jsondb/.
	cp -r ${OPENHAB_SETUP_SOURCE}/html ${OPENHAB_SETUP_CONF}/html/.
	mkdir ${OPENHAB_SETUP_CONF}/html/floorplans
	cp -r ${OPENHAB_SETUP_SOURCE}/images/floorplans/* ${OPENHAB_SETUP_CONF}/html/floorplans
	cp -r ${OPENHAB_SETUP_SOURCE}/images/classic/* ${OPENHAB_SETUP_CONF}/icons/classic

	chown -R openhab:openhab ${OPENHAB_SETUP_USERDATA}
	chown -R openhab:openhab ${OPENHAB_SETUP_CONF}

	export BINDING_SELECT="astro lcn mqtt network systeminfo openweathermap ephemeris"
	echo $BINDING_SELECT
	inst-select
	
	function-openhab-start   ## call funtion

	return $RETVAL
}


#######################################################################
#######################################################################
inst-core() {

	function-check-prod  # if the current system is PRD, we stop

	if [ "${OPENHAB_DOCKER}" == "true" ];
	then
		echo "Docker was set - do not install local software"
		return $RETVAL
	fi

	apt-get update
	apt-get install openhab=${OPENHAB_VERSION}-1 openhab-addons=${OPENHAB_VERSION}-1 -y
	sudo systemctl daemon-reload
	sudo systemctl enable openhab.service

   	echo 
	sudo systemctl start openhab
	echo
	echo "core installation finished."
	echo "the openhab has been started."
	echo 
	echo "THE INITAIL START NEED 3-5 MINUTES - WAIT!"
	echo
	echo "Please logon and make the basic settings!"
	echo
	echo "your location is : "${OPENHAB_LOCATION}
	echo
	echo "klick INSTALL ADDONS LATER... - you can do it via -c inst-select"
	echo

	while true; do
		read -p "Did you finish the basic settings y/n ? " yn
		case $yn in
			[Yy]* ) echo "we go on"; break;;
			[Nn]* ) return $RETVAL;;
			* ) echo "Please answer yes or no.";;
		esac
	done

	return $RETVAL
}


#######################################################################
#######################################################################
# This is only possible, if you have an backup running for your productiv server running.
# check the folder z-backup
#######################################################################
back-restore-prd() {

	function-check-prod  # if the current system is PRD, we stop
	
    LAST_BACKUP=`ls -trl ${BACKUP_PATH}/${OPENHAB_PRD_HOSTNAME}.fritz.box/ | grep openhab-backup | tail -1 | cut -c 48- | cut -d- -f3- | cut -d. -f1`
	echo "... last backup date : "${LAST_BACKUP}
	echo "... hostname prd     : "${OPENHAB_PRD_HOSTNAME}
	echo "... copy files ... wait"
	pwd
	cp ${BACKUP_PATH}/${OPENHAB_PRD_HOSTNAME}.fritz.box/*${LAST_BACKUP}*.zip /tmp
	cp ${BACKUP_PATH}/${OPENHAB_PRD_HOSTNAME}.fritz.box/openhab-db-${OPENHAB_PRD_HOSTNAME}-*${LAST_BACKUP}.sql.gz /tmp

	cd /tmp
	ls -l *${LAST_BACKUP}*

	uncompress *${LAST_BACKUP}.sql.gz
	mv /tmp/*${LAST_BACKUP}.sql ${OPENHAB_DB_BASE}/

	echo
	echo "Start Restore PRD"
	echo
	function-openhab-stop   ## call funtion
	echo "!!! ToDo - check that mariadb is running as expected"

	if [ -d "${OPENHAB_RESTORE}" ]; then
	### Take action if ${OPENHAB_RESTORE} exists ###
		echo "... Installing config files in ${DIR}..."
		rm -R ${OPENHAB_RESTORE}
		mkdir ${OPENHAB_RESTORE}
	else
	###  Control will jump here if ${OPENHAB_RESTORE} does NOT exists ###
		echo "... Error: ${DIR} not found. Create it."
		mkdir ${OPENHAB_RESTORE}
	fi
	echo "... unzip in quite mode"	

	cd ${OPENHAB_RESTORE}

	pwd
	unzip -q ../*${LAST_BACKUP}*.zip

	# prepare restore into test environment
	rm -R backup.properties userdata/uui* userdata/openhabcloud/secret* userdata/logs userdata/etc/users.properties
	rm -R userdata/jsondb/users.json userdata/etc/keystore userdata/etc/host.k* userdata/secrets/* userdata/jsondb/backup/*
	cd conf/rules
	mv *.rules off/.
	mv off/Datalogging.rules off/mqtt_* off/squeezebox.rules .
	mv off/Noti* off/Init.rules off/Mon* off/ephemeris.rules off/exec.rules off/network.rules .
	mv off/avmfritz.rules off/lcnAction.rules off/worxlandroid.rules .
	cd ../services/
	FILE=jdbc.cfg
	if [ -f "${FILE}" ]; then
		echo "... replace DB ip-address in : "${FILE}
		find . -name ${FILE}  -type f -exec sed -i 's/10.10.10.68/10.10.10.125/g'  {} \;
	else
		echo "... replace - file not found : "${FILE}
	fi
	cd ../things
	mv telegram* off/.
	cd ../..
	echo "hier stehe ich : "
	pwd
	ls -l ${OPENHAB_DOCKER_BASE}/data
	mv ${OPENHAB_DOCKER_BASE}/data ${OPENHAB_DOCKER_BASE}/data-`date +%Y%m%d-%H%M%S`

	mkdir ${OPENHAB_DOCKER_BASE}/data
	cp -R * ${OPENHAB_DOCKER_BASE}/data/.
	chown -R openhab:openhab  ${OPENHAB_DOCKER_BASE}/data
	rm -rf ${OPENHAB_LOGPATH}/openhab.log

#	echo "... restore latest database"
#    read -p "   push >Enter< to go on -db1"
#	FILE=openhab-db-${OPENHAB_PRD_HOSTNAME}-${LAST_BACKUP}.sql
#	echo " file : "$FILE
#	docker exec -it mariadb mariadb -uroot -ppassword openhab < $FILE
#	echo "... restore db finisehd"
#    read -p "   push >Enter< to go on -db2"

	function-openhab-start					## call function
	sleep 10s
	function-openhab-check-running			## call function

	echo "....done back-restore-prod"
	return $RETVAL
}


#######################################################################
#######################################################################
back-select() {

	echo "Backup selected bindings"

	cd ${OPENHAB_SETUP_SOURCE}

	for FILE in $BINDING_SELECT
	do
		echo "work on >> "$FILE
		. ${OPENHAB_SETUP_SOURCE}/binding-astro/backup.bash binding-astro
	done

	return $RETVAL
}


#######################################################################
#######################################################################
function-openhab-stop() {

	echo ""

	if [ "${OPENHAB_DOCKER}" == "true" ];
	then
		echo "Docker was set... stopping"
		docker stop openhab
		echo "Docker was set... stopped"
	else
		echo "openhab stopping"
		sudo systemctl stop openhab.service
	fi

	return $RETVAL
}

#######################################################################
#######################################################################
function-openhab-start() {

	echo ""
	echo "openhab START"

	if [ "$OPENHAB_DOCKER" == "true" ];
	then
		echo "Docker was set...- start again"
		docker start openhab
		echo "Docker was set...- started - check openhab.log"
	else
		sudo systemctl start openhab.service
	fi

	function-openhab-check-running

	return $RETVAL
}


#######################################################################
#######################################################################
inst-select() {

	echo
	echo "...keep in mind, perhaps you have to install the corresponding bindings manually."
	echo
#	read -p "   push >Enter< to go on  "
	echo

	cd ${OPENHAB_SETUP_SOURCE}

	########################
	# now copy goes on
	########################
	for VARIABLE in $BINDING_SELECT
	do
		if [ "${VARIABLE}" != '-b' ] &&  [ "${VARIABLE}" != '-c' ] &&  [ "${VARIABLE}" != 'inst-select' ]
		then
			echo ${VARIABLE}
			. ${OPENHAB_SETUP_SOURCE}/binding-${VARIABLE}/install.bash binding-${VARIABLE}
		fi
	done
	echo
	echo "copy was done..."

	cd ${OPENHAB_SETUP_CONF}
	chown -R openhab:openhab *

	sudo rm -rf $OPENHAB_SETUP_USERDATA/cache/*
	sudo rm -rf $OPENHAB_SETUP_USERDATA/tmp/* 
	echo; echo "start openhab - wait 1-3 minutes, depend on the machine power !"; echo

   return $RETVAL
}



#######################################################################
#######################################################################
back-all() {

	if [ `hostname` == "${OPENHAB_PRD_HOSTNAME}" ];
	then
		echo "...running on prod machine..."
	else
		echo "!!!!!!!!!!!!1"
		echo "Full Backup is only possible on the prod machine"
		echo "!!!!!!!!!!!!1"
		exit
	fi

	cd $OPENHAB_SETUP_CONF

	echo "CONF     = "${OPENHAB_SETUP_CONF}
	echo "SOURCE   = "${OPENHAB_SETUP_SOURCE}
	echo "UserData = "${OPENHAB_SETUP_USERDATA}

	cd ${OPENHAB_SETUP_SOURCE}

	rm -R /tmp/openhab-backup

	mkdir /tmp/openhab-backup
	mkdir /tmp/openhab-backup/config
	mkdir /tmp/openhab-backup/images
	mkdir /tmp/openhab-backup/rules
	mkdir /tmp/openhab-backup/html
	cd /tmp/openhab-backup


	echo "-x-x-x-x-x"
	cp ${OPENHAB_SETUP_CONF}/sitemaps/default.sitemap config/.
	cp ${OPENHAB_SETUP_CONF}/services/*.cfg config/.
	cp ${OPENHAB_SETUP_CONF}/persistence/*.persist config/.
	cp -r ${OPENHAB_SETUP_CONF}/html html/.
	cp -r ${OPENHAB_SETUP_CONF}/rules rules/.
	cp ${OPENHAB_SETUP_USERDATA}/jsondb/uicomponents_ui_*.json config/.

	########################
	# now copy goes on
	########################
	. ${OPENHAB_SETUP_SOURCE}/binding-astro/backup.bash binding-astro
	. ${OPENHAB_SETUP_SOURCE}/binding-avmfritz/backup.bash binding-avmfritz
	. ${OPENHAB_SETUP_SOURCE}/binding-comfoair/backup.bash binding-comfoair
	. ${OPENHAB_SETUP_SOURCE}/binding-ephemeris/backup.bash binding-ephemeris
	. ${OPENHAB_SETUP_SOURCE}/binding-exec/backup.bash binding-exec
	. ${OPENHAB_SETUP_SOURCE}/binding-ipcamera/backup.bash binding-ipcamera
	. ${OPENHAB_SETUP_SOURCE}/binding-lcn/backup.bash binding-lcn
	. ${OPENHAB_SETUP_SOURCE}/binding-landroid/backup.bash binding-landroid
	. ${OPENHAB_SETUP_SOURCE}/binding-mail/backup.bash binding-mail
	. ${OPENHAB_SETUP_SOURCE}/binding-mqtt-instar/backup.bash binding-mqtt-instar
	. ${OPENHAB_SETUP_SOURCE}/binding-mqtt-rctmon/backup.bash binding-mqtt-rctmon
	. ${OPENHAB_SETUP_SOURCE}/binding-mqtt-vzlogger/backup.bash binding-mqtt-vzlogger
	. ${OPENHAB_SETUP_SOURCE}/binding-modbusstiebel/backup.bash binding-modbusstiebel
	. ${OPENHAB_SETUP_SOURCE}/binding-network/backup.bash binding-network
	. ${OPENHAB_SETUP_SOURCE}/binding-openweathermap/backup.bash binding-openweathermap
	. ${OPENHAB_SETUP_SOURCE}/binding-shelly/backup.bash binding-shelly
	. ${OPENHAB_SETUP_SOURCE}/binding-solarforecast/backup.bash binding-solarforecast
	. ${OPENHAB_SETUP_SOURCE}/binding-squeezebox/backup.bash binding-squeezebox
	. ${OPENHAB_SETUP_SOURCE}/binding-systeminfo/backup.bash binding-systeminfo
	. ${OPENHAB_SETUP_SOURCE}/binding-telegram/backup.bash binding-telegram
	. ${OPENHAB_SETUP_SOURCE}/binding-tr064/backup.bash binding-tr064
	. ${OPENHAB_SETUP_SOURCE}/binding-testing/backup.bash binding-testing
	return $RETVAL
}


#######################################################################
#######################################################################
inst-all() {

	inst-base

	inst-core

	inst-default

	inst-db

	return $RETVAL
}

#######################################################################
#######################################################################
env() {

	echo "env ...start..."

	echo "OPENHAB_VERSION        : " $OPENHAB_VERSION
	echo "OPENHAB_DOCKER_BASE    : " $OPENHAB_DOCKER_BASE
	echo "OPENHAB_SETUP_CONF     : " $OPENHAB_SETUP_CONF
	echo "OPENHAB_SETUP_USERDATA : " $OPENHAB_SETUP_USERDATA
	echo "OPENHAB_SETUP_ADDONS   : " $OPENHAB_SETUP_ADDONS
	echo "OPENHAB_SETUP_SOURCE   : " $OPENHAB_SETUP_SOURCE
	echo "OPENHAB_DOCKER         : " $OPENHAB_DOCKER

	echo
	echo "env ...ende..."
	echo
	read -p "   push >Enter< to go on  "

	return $RETVAL
}

#######################################################################
#######################################################################
inst-list() {

	echo
	echo "## possible bindings in your source :"
	echo
	for FILE in $BINDING_SOURCE
	do
		echo $FILE
	done
	echo
	echo "Example : ./1-setup.bash -c inst-select -b astro systeminfo network"
	echo

	return $RETVAL
}

#######################################################################
#######################################################################
function-openhab-check-running() {

	FILE=${OPENHAB_LOGPATH}/openhab.log
	echo 
	echo "check if openhab is running : "${FILE}
	sleep 10 
	while true; do
		START_STATUS=`grep RuleEngineImpl ${FILE}`

		if [ -z "$START_STATUS" ]; then
			echo "function-openhab-check-running - still watching for a line with >RuleEngineImpl<"
		else
			echo "function-openhab-check-running - openhab is up and running. Try to access."
			exit
		fi
		sleep 5
	done
	echo 

	return $RETVAL
}


#####################################################################
# start Arguments

while getopts b:c:h: flag
do
    case "${flag}" in
        b)
			BINDING_SELECT=$@
			echo "## You set individual bindings : "
			echo $BINDING_SELECT
			init-check_installed_bindings
			;;
        c) 
			COMMAND=${OPTARG}
			echo "## Command :"
			echo $COMMAND
			;;
        h) 
			echo "hilfe "
			;;
    esac
done

#######################################################################
#######################################################################

# clear
case "$COMMAND" in
  env)
        env
	;;

  inst-base)
        clear
        echo "...................................................................."
        echo "...       installing openhab environment .... user/group/dirs...    "
        echo "...................................................................."
        echo;  echo; read -p "push >Enter< to go on"

		inst-base

        echo; echo "...done"; echo
        echo "   next install >inst-core<"; echo 
        read -p "   push >Enter< to go on"
	;;
  inst-core)
        clear
        echo "........................................................................."
        echo "...       installing openhab core"
        echo "........................................................................."
        echo
        read -p "   push >Enter< to go on  "
		echo

        inst-core

        echo ; echo "   ...done"; echo

		echo "   please go on with the fist steps in the openhab GUI!"
		echo "   from the astro bindings, i think your location is : "${OPENHAB_LOCATION}

		echo
		echo "   than ...."
		echo

        echo "   next install >inst-default<"; echo 
        read -p "   push >Enter< to go on"
	;;

  inst-default)
        clear
        echo "....................................................................."
        echo "...       installing some default settings from the old installation "
        echo "....................................................................."

		inst-default

        echo; echo "...done"; echo
        echo "   next install >inst-db<"; echo 
        read -p "   push >Enter< to go on"
	;;

  inst-example)
        clear
        echo "....................................................................."
        echo "...       installing an example setup "
        echo "....................................................................."

		inst-example

        echo; echo "...done"; echo
        read -p "   push >Enter< to go on"
	;;

  inst-db)
        clear
			echo "Installing config files in ${DIR}..."
	        echo "........................................................................."
	        echo "...       installing database" 
	        echo "........................................................................."
	        echo
			echo
			read -p "   push >Enter< to go on  "
			echo

   			inst-db

	        echo ; echo "   ...done"; echo
			echo "   next install >inst-select<"; echo 
        	read -p "   push >Enter< to go on"
	;;

  back-all)
        clear
        echo "...................................................................."
        echo "...       backup-all"
        echo "...................................................................."
        echo
        echo
        read -p "push >Enter< to go on"

        back-all

        echo ; echo "...done"; echo
        read -p "push >Enter< to go on"
	;;

  inst-list)
        inst-list
	;;

  inst-all)
        inst-all
	;;

  inst-select)
        inst-select
	;;

  docker-default) 
        docker-default
	;;

  docker-reset)
        docker-reset
	;;

  back-select)
		back-select
	;;

  back-restore-prd)
		back-restore-prd
	;;

	remove)
		remove
	;;
	*)
		echo 
		echo "  ####################################################################"
		echo "  #         parameter missing - try again ;-)                        # "
		echo "  ####################################################################"
		echo 
		echo "  Usage   :   $0 -c command [-b 'name name ...]"
		echo 
		echo "  Example : ./1-setup.bash -c inst-list"
		echo "  Example : ./1-setup.bash -c inst-select -b astro"
        echo "  Example : ./1-setup.bash -c inst-select -b astro systeminfo network"
   	    echo
		echo "  -c  one of these commands"
        echo
        echo "    env              - step 10 display the current variables in use"
        echo
		echo "    ###############################################################"
        echo "    inst-...         - 21-24 nativ installation into unix os"
        echo "    inst-base        - step 21 prepare the environment"
        echo "    inst-core        - step 22 install openhab core"
        echo "    inst-default     - step 23 install openhab core"
        echo "    inst-db          - step 24 install openhab database"
		echo
        echo "    inst-example     - step 26 install an example setup"
		echo
        echo "    inst-all         - step .. install 21,22,23,24 (experimental)"
		echo 
		echo "    ###############################################################"
		echo 
        echo "    inst-list        - step 50 list all addons from you source"
		echo "                     (the list is detected by the folders name behind 'binding-'"
        echo "    inst-select      - step 51 install bindings from parameter -b"
		echo
		echo "    back-select      - stop 61 backup the selected files"
		echo "                     (the list is detected by the folders name behind 'binding-'"
		echo "    back-all         - step 70 backup configuration into the source folders"
		echo
		echo "    ###############################################################"
		echo 
        echo "    docker-reset     - step 70 reset the installation"
        echo "    docker-default   - step 71 install default"
		echo
		echo "    back-restore-prd - step 80 restore last prd backup"
		echo
        echo "    remove           - step 90 will remove / purge the installation"
        echo
		echo "  -b  select bindings you will work on"
		echo
        ;;
esac
