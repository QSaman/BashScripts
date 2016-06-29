#!/bin/bash
#Below script sort all images by modification date, then rename them to 01.jpg, 02.jpg,...
cnt=1
for i in `ls -tr *.jpg`
do
    name=`printf "./res/%02i.jpg" $cnt`
    cp $i $name
    cnt=$(($cnt+1))
done
