# crontab entry 
45 0 25 * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
05 0 25 * * /usr/local/bin/openhab-backup.sh >> /var/log/openhab-backup.log 2>&1
