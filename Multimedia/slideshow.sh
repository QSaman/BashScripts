#!/bin/bash

#The requirement for this script is baloo and feh
#Note that this script cannot show multiple-frames images like most gifs

delay=10

if [ $# -ne 1 ]
then
    dirPath="."
else
    dirPath="$1"
fi

baloosearch -d"$dirPath" -t image "rating>=10" | feh -F -D $delay -Z -z -Y -f - 
