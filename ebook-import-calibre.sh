#!/bin/bash
echo removing all the old covers
find ./ -name "*cov0001.htm" | xargs rm
for i in * 
do 
author=`echo $i | sed s/\ -.*//`
y=`echo Nocturne - $i | sed s/\(html\)//g | sed s/"$author - "// | sed s/\(.*//g`
htm=`find "$i" -iname "*.htm*"`
rtf=`find "$i" -iname "*.rtf"`
doc=`find "$i" -iname "*.doc"`
if [ -n "$htm" ];then 
ebook-convert "$htm" "$y.epub" --title "$y" --authors "$author"
calibredb add "$y.epub"
fi
if [ -r "$rtf" ];then 
htmlname=`echo $rtf | sed 's/\.doc$/\.html/'`
wvHtml "$rtf" "$htmlname"
ebook-convert "$htmlname" "$y.epub" --title "$y" --authors "$author"
echo calibredb add "$htmlname" -a "$author"
fi
if [ -n "$doc" ];then 
htmlname=`echo $doc | sed 's/\.doc$/\.html/'`
wvHtml "$doc" "$htmlname"
ebook-convert "$htmlname" "$y.epub" --title "$y" --authors "$author"
calibredb add "$y.epub" 
fi
done


