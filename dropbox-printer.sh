#!/bin/bash
for file in `ls /home/velofille/Dropbox/printer/new/`
do lp -d laser "/home/velofille/Dropbox/printer/new/$file" | mail -s "Print Job"  liz@velofille.com
mv "/home/velofille/Dropbox/printer/new/$file" /home/velofille/Dropbox/printer/done/
done

