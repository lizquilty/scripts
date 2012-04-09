#!/bin/bash
if [ ! -z "$1" ];then
mencoder dvd:// -alang en -ovc xvid -xvidencopts bitrate=1200 -vf scale -oac mp3lame -lameopts br=128 -o $1
fi
