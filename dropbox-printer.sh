#!/bin/bash

# cd your dropbox dir
# mkdir -p $DROPDIR/printer/new
# mkdir -p $DROPDIR/printer/done

DROPDIR=/home/velofille/Dropbox/printer/
EMAILADMIN=liz@velofille.com

cd $DROPDIR
find ./ | while read file 
do lp -d laser "$DROPDIR/new/$file" | mail -s "Print Job"  $EMALIADMIN
mv "$DROPDIR/new/$file" $DROPDIR/done/
done

