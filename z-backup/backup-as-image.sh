#!/bin/sh
# by strobelstefan.de
# 2018-05-24
# Version: 1.0
# https://strobelstefan.org/?p=5985
#https://strobelstefan.org/wp-content/uploads/2018/05/RPI-Image-Homepage.txt

#
# This script creates a full clone of you Raspberry Pi´s SD card.
#

# Ralf 2021.11.28
# Script angepasst auf meine Umgebung
#
# Info zum Umgang mit USB Device
# https://znil.net/index.php/EXT4_Festplatte_am_Raspberry_Pi_mounten_und_formatieren
#


###################################
# Define Variables
###################################

# Storage device as defined in you /etc/fstab.
#mountpoint='/home/pi/storage/'
mountpoint='/backup'
HOST=`hostname`

#Path were the image of your SD card should be saved to
#STORAGEPATH="/home/pi/storage/RPiImages/DSNAS" 
STORAGEPATH=/backup/backup-as-image/${HOST}.fritz.box

# E-Mail Address
EMAIL="yourmail@localhost"

# Location of your log file
LOGFILE="/var/log/backup-as-image.log"


###################################
# LOG File Section - Log File
###################################
# This removes your old log file
rm ${LOGFILE}

###################################
# MOUNTPOINT Section - Check Mountpoint Availability
###################################
# It checks if your mountpoint is accessible by your RPi.
# This is a crucial step, if the sotrage is not available the clone process of the SD card cannot conducted.
# Process
# 1. Check if mountpoint is accessible
# 2. If YES go to DELETION Section
# 3.1 If NO, try to mount storage device as defined in /etc/fstab
# 3.2 If mount is again not sucessful exit script, no futher action will be conducted

if [ "$(findmnt ${mountpoint})" ] ;
	then
		echo $(date +%Y-%m-%d_%H-%M-%S) " - mountpoint accessible by your Raspberry Pi" >> ${LOGFILE}
	else
		echo $(date +%Y-%m-%d_%H-%M-%S) " - mountpoint was not accessible, try to mount it now as defined in your /etc/fstab" >> ${LOGFILE}

	#This command mounts all storages defined in /etc/fstab
	mount -a

	if [ $? != 0 ]
		then
			echo $(date +%Y-%m-%d_%H-%M-%S) " - Mount of storage in first try sucessfully completed" >> ${LOGFILE}
		sleep 5
			mount -a
		if [ $? != 0 ]
		then
			echo $(date +%Y-%m-%d_%H-%M-%S) " - Backup FAILED! Was not able to mount your storage device. Stop backup process. You have to check it manually." >> ${LOGFILE}
			#echo "Sent backup status via e-mail" | mail -a ${LOGFILE} -s "DSNAS Pi - Backup FAILED" ${EMAIL} < ${LOGFILE}
		exit
		fi
	fi

fi	


##################################################################
# DELETION Section - Remove old Images from Storage Device
##################################################################
# Use this command with CAUTION!
# This will help you to automatically remove old images from your storage device to avoid that your
# storage will run out of space


echo $(date +%Y-%m-%d_%H-%M-%S) " - Start to delete files older than defined time " >> ${LOGFILE}


# Uncomment if the files should be identified by days, file > 30 days than it gets deleted
#find ${STORAGEPATH}/*.* -mtime +30 -exec rm -r {} \;

# Uncomment if you would like to use minutes file > 10080 minutes than it gets deleted
find ${STORAGEPATH}/*.* -type f -mmin +43200 -exec rm {} \;

if [ $? != 0 ]
	then
		echo $(date +%Y-%m-%d_%H-%M-%S) " - Deletion of old image files sucessfully completed" >> ${LOGFILE}
	 if [ $? != 0 ]
	 then
		echo $(date +%Y-%m-%d_%H-%M-%S) " - Was not able to delete old image files. You have to check it manually." >> ${LOGFILE}
	break
	fi
fi
	


###################################
# CLONE Section - Clone SD Card Image 
###################################
# This line creates a full copy of the SD card and writes it as an image file to the defined patch

echo $(date +%Y-%m-%d_%H-%M-%S) " - Started to clone image" >> ${LOGFILE}

# Uncomment this line if you would likt to save a plain img file on your storage device
sudo dd if=/dev/mmcblk0 of=${STORAGEPATH}/${HOST}$(date +%Y-%m-%d).img bs=1MB

# Uncomment this line if you would like to save the image as a compressed file
# If you would like to restore your image, you can do it via this command on your local machine
# diskutil unmountDisk /dev/disk#
# gzip -dc ~/Desktop/pibackup.gz | sudo dd of=/dev/rdisk# bs=1m conv=noerror,sync
# see for further information --> https://johnatilano.com/2016/11/25/use-ssh-and-dd-to-remotely-backup-a-raspberry-pi/

#sudo dd if=/dev/mmcblk0 bs=1M | gzip - | dd of=${STORAGEPATH}/$(HOST)$(date +%Y-%m-%d).gz

if [ $? != 0 ]
	then
		echo $(date +%Y-%m-%d_%H-%M-%S) " - Image file created" >> ${LOGFILE}
	 if [ $? != 0 ]
	then
		echo $(date +%Y-%m-%d_%H-%M-%S) " - Was not able to create your image file. You have to check it manually." >> ${LOGFILE}
	break
	fi
fi



###################################
# UMOUNT Section - Unmount Storage Device
###################################
# This command unmounts the defined storage device
# In the first try it will gently try to unmount, if the device is busy the comand will force the unmount.

#echo $(date +%Y-%m-%d_%H-%M-%S) " - Started to unmount storage device">> ${LOGFILE}

#umount ${mountpoint}

#if [ $? != 0 ]
#	then
#		echo $(date +%Y-%m-%d_%H-%M-%S) " - Device busy, unmount forcefully" >> ${LOGFILE}
#	sleep 5
#		umount -l ${mountpoint}
#	if [ $? != 0 ]
#    then
#        echo $(date +%Y-%m-%d_%H-%M-%S) " - Issue with umount you storage, check manually" >> ${LOGFILE}
#    break
#	fi
#fi

	
echo $(date +%Y-%m-%d_%H-%M-%S) " - Mission Accpmplished!!!" >> ${LOGFILE}

#echo "Sent backup status via e-mail" | mail -a ${LOGFILE} -s "DSNAS Pi - Backup SUCCESSFULL" ${EMAIL} < ${LOGFILE}
echo "Sent backup status via e-mail" >> ${LOGFILE} 
