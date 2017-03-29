#!/bin/bash
# This is a terrible script, nobody should really use it 
# It  assumes you have lots of groups of 3 photos , and makes them into a hdr file, then opens them in qtpfsgui for you to tweak.
# Only ever useful if you took a ton of HDR and want to weed them out before finishing them up

n=0 
hdr=0 
for i in `ls *.CR2 | sort` ; do echo $i 
  if [ $n -eq 3 ];then 
	hdr=$(($hdr+1))
	n=0
	echo $i going in hdr${hdr}
	mv $i hdr${hdr}/ 
  else 
	echo $i going in hdr${hdr}
	mv $i hdr${hdr}/ 
  fi 
   n=$(($n+1))
done

for dir in * 
	 do pwd=$(pwd) 
	 echo going to $dir 
	 cd $dir 
	 qtpfsgui -a MTB -s image.hdr -o images.jpg *.CR2 
	 echo going to $pwd 
	 cd $pwd
done

