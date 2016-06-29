#!/bin/bash

#The requirement for this script is baloo and sxiv
#Note that this script can show multiple-frames images like most gifs

delay=10

if [ $# -ne 1 ]
then
    dirPath="."
else
    dirPath="$1"
fi

baloosearch -d"$dirPath" -t image "rating>=10" | sort --random-sort | sxiv -a -b -f -i -S $delay -sf
