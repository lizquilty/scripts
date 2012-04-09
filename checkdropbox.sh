#!/bin/sh
SERVICE='/home/velofille/.dropbox-dist/dropbox'
 
if ! ps ux | grep -v grep | grep $SERVICE > /dev/null
then
    /home/velofille/.dropbox-dist/dropbox &
    echo "$SERVICE is not running! Had to restart it" | mail -s "$SERVICE down" liz@velofille.com
fi
