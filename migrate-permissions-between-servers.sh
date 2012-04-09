#!/bin/bash
ORIGIN="/mnt"
ROOTFS="/"

rm -f filepermfix.sh
touch filepermfix.sh

find ${ORIGIN} | sed s@"${ORIGIN}"@@ | while read FFILE 
do
echo working with "${ORIGIN}${FFILE}"
UIDGID=$(stat -c "%u:%g" "${ORIGIN}${FFILE}")
CHMOD=$(stat -c "%a" "${ORIGIN}${FFILE}")
echo chown ${UIDGID} "${ROOTFS}${FFILE}" >>filepermfix.sh
echo chmod ${CHMOD} "${ROOTFS}${FFILE}" >>filepermfix.sh
done
echo now on the 
