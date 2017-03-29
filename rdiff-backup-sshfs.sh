#!/bin/bash
# Version 1.6
# Changelog: Adding variable $FTPHOST
#
# Prior to running this make sure you have ssh-keygen -t rsa to generate a key, then 
# ssh username@backupspace.rimuhosting.com "mkdir .ssh/;chmod 700 .ssh"
# scp .ssh/id_rsa.pub username@backupspace.rimuhosting.com:.ssh/authorized_keys
#
# then check you can login and accept the ssh key
# ssh username@backupspace.rimuhosting.com "ls -la"
#
# Key things to remember, no spaces in pathnames, and try to use fill paths (beginning with / ) 
#
# now fill in these few variables for me

USERNAME=yourusername

# This is whatever host you connect too - eg host2.bakop.com 
FTPHOST=backupspace.rimuhosting.com


INCLUDES="/etc/apache2 /var/www" #this is a list of directories you want backed up
EXCLUDES="*.mp3 *.avi" #this is a list of files etc you want to skip
# I added a mysql user called backup with permissions to SELECT and LOCKING only for this backup
# CREATE USER backup@'localhost' IDENTIFIED BY 'somepass';
# GRANT SELECT,LOCK TABLES ON *.* TO backup@'localhost'  WITH GRANT OPTION;

MYSQLBACKUP=1
DBUSER=backup
DBPASS=somepass

# This is what we remove, any backups older than 4 weeks = 4W 
OLDERTHAN=4W
# too delete files older than 4 weeks then uncomment this line
RMARGS=" --force --remove-older-than ${OLDERTHAN}"

# this stuff is probably not needing to be changed
HOSTNAME=`hostname`
TMPDIR=/backups
DATESTAMP=`date +%d%m%y`
ARGS=" -v0 --terminal-verbosity 0 --exclude-special-files --exclude-other-filesystems --no-compression -v6"
temp=/tmp/temp.txt

# detecting distro and setting the correct path
if [ -e /etc/debian_version ];then
	NICE=/usr/bin/nice
elif [ -e /etc/redhat-release ];then
	NICE=/bin/nice
fi


if [ -e /tmp/backup.lock ];then
	exit 0
fi
touch /tmp/backup.lock


cd /
/bin/mkdir -p ${TMPDIR}/sshmnt
/bin/mkdir -p ${TMPDIR}/db

/usr/bin/sshfs -o workaround=rename ${USERNAME}@${FTPHOST}: ${TMPDIR}/sshmnt &&
/bin/mkdir -p ${TMPDIR}/sshmnt/${HOSTNAME}/ &&
# if you get errors mounting this then try 
# mknod /dev/fuse -m 0666 c 10 229

if [ $MYSQLBACKUP = 1 ];then
        databases=( $(/usr/bin/mysql -u"${DBUSER}" -p"${DBPASS}" --skip-column-names --batch -e "show databases;" 2>"$temp") );
        for dbbk in ${databases[@]}; do
                if [ $dbbk != "information_schema" ] && [ $dbbk != "test" ]; then
                      /usr/bin/mysql -u"${DBUSER}" -p"${DBPASS}" -D "$dbbk" --skip-column-names --batch -e "optimize table $i" 2>"$temp" >/dev/null
                      /usr/bin/mysqldump -u"${DBUSER}" -p"${DBPASS}" --opt $dbbk | bzip2 -c > "${TMPDIR}/db/$dbbk.sql.bz2"
         fi
  done

		ARGS="${ARGS} --include ${TMPDIR}/db/ "
fi

for ITEMI in ${INCLUDES} ; do
	                ARGS="${ARGS} --include ${ITEMI} "
done
for ITEME in ${EXCLUDES} ; do
	                ARGS="${ARGS} --exclude-regexp '${ITEME}' "
done
# the --exclude ** / is a hack because it wont by default do multiple dirs, so use --include for all dirs then exclude everything else and sync / - if you dont understand dont worry 
# ref: http://www.mail-archive.com/rdiff-backup-users@nongnu.org/msg00311.html
#echo /usr/bin/rdiff-backup ${ARGS} --exclude \'**\' / ${TMPDIR}/sshmnt/${HOSTNAME}/ &&
${NICE} -19 /usr/bin/rdiff-backup ${ARGS} --exclude '**' / ${TMPDIR}/sshmnt/${HOSTNAME}/ >/dev/null 2>&1 &&
#echo Removing backups older than ${RMARGS}
/usr/bin/nice -19 /usr/bin/rdiff-backup -v0 --terminal-verbosity 0  ${RMARGS} ${TMPDIR}/sshmnt/${HOSTNAME}/  
/bin/umount ${TMPDIR}/sshmnt && /bin/rm -rf ${TMPDIR}/


rm /tmp/backup.lock
