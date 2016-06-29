#!/bin/bash

#The requirement for this script is baloo and mpv

minRating=10

if [ $# -ne 1 ]
then
    dirPath="."
else
    dirPath="$1"
fi

#At the moment baloo has a bug and doesn't recognize some vide types like wmv. Below is a temporary solution:
function handlBalooBug
{
    mpv --shuffle --playlist <(cat <(baloosearch -d"$dirPath" -t Video "rating>=${minRating}") <(baloosearch -d"$dirPath" "rating>=${minRating}" | egrep -i '\.wmv$|\.mkv$'))
}


#mpv --shuffle --playlist <(baloosearch -d"$dirPath" -t video "rating>=${minRating}")
handlBalooBug
#baloosearch -d"$dirPath" -t video "rating>=10" | mpv --shuffle --playlist=/dev/fd/3 3<&0 < /dev/tty
