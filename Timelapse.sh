#!/bin/bash
# This assumes that first argument is a directory of CR2 files and you have imagemagick and mencoder install

if [ $1 ];then
    WDIR=$1
    ufraw-batch  ${WDIR}/*.CR2
    for i in ${WDIR}/*.ppm ; do y=$(echo $i | sed s/.ppm/.jpg/) ;echo converting $i to $y; convert -resize 1024x1024 $i $y ; done
    echo listing into text file
    ls -1tr ${WDIR}/*.jpg > ${WDIR}/files.txt
    echo Encoding
    mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4 -o ${WDIR}/video.avi -mf type=jpeg:fps=10 mf://@${WDIR}/files.txt
else
    echo Usage: $0 directory
fi

