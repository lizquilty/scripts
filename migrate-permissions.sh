#!/bin/bash
ORIGIN="/home/velofille"
ROOTFS="/tmp"


find ${ORIGIN} | sed s@"${ORIGIN}"@@ | while read FFILE 
do
echo working with "${ORIGIN}${FFILE}"
UIDGID=$(stat -c "%u:%g" "${ORIGIN}${FFILE}")
CHMOD=$(stat -c "%a" "${ORIGIN}${FFILE}")
chown ${UIDGID} "${ROOTFS}${FFILE}"
chmod ${CHMOD} "${ROOTFS}${FFILE}"
done
