#!/bin/bash

#The requirement for this script is baloo and feh and/or sxiv and/or mpv

delay=10
criteria="rating=10"
dirPath="."
viewerName="feh"
balooBug="0"

function showUsage
{
    echo "Usage:"
    echo "$0 [options]"
    echo "Options:"
    echo "-h, --help:           Show this help"
    echo "-r, --rating:         Minimum rating: e.g. -r 8 means rating>=8. The default is rating=10."
    echo "-c, --criteria:       Criteria: e.g. -c rating=9. The default is rating=10."
    echo "-p, --path:           Path to the root directory to show images. The default is the current directory (.)."
    echo "-d, --delay:          Delay for slideshow. The default is 10s."
    echo "                      Note that you can use delay when you've chosen an image viewer."
    echo "-s, --software:       Image viewer or video player." 
    echo "                      Supported image viewers: feh, sxiv"
    echo "                      Note that feh unable to show multiple-frames images like most gifts. On the other hand sxiv can do that."
    echo "                      Supported video players: mpv"
    echo "-b, --bug             At the moment baloo has a bug and doesn't recognize some vide types like wmv. Use this to temporary solve it."
    exit 0
}

while [ $# -gt 0 ]
do
    key="$1"
    case $key in
        -h|--help)
            showUsage
            shift
            ;;
        -r|--rating)
            if [ "$2" = "" ]
            then
                showUsage
            fi
            criteria="rating>=${2}"
            shift 2
            ;;
        -c|--criteria)
            criteria="${2}"
            if [ "$2" = "" ]
            then
                showUsage
            fi
            shift 2
            ;;
        -p|--path)
            dirPath="$2"
            if [ "$dirPath" = "" ]
            then
                showUsage
            fi
            shift 2
            ;;
        -d|--delay)
            delay="$2"
            if [ $delay = "" ]
            then
                showUsage
            fi
            shift 2
            ;;
        -s|--software)
            viewerName="$2"
            if [ "$viewerName" = "" ]
            then
                showUsage
            fi
            shift 2
            ;;
        -b|--baloo-bug)
            balooBug="1"
            shift
            ;;
        *)
            showUsage
            ;;
    esac
done

#At the moment baloo has a bug and doesn't recognize some vide types like wmv. The following function is a temporary solution:
function runMpvAndHandlBalooVideoBug
{
    mpv --shuffle --playlist <(cat <(baloosearch -d"$dirPath" -t Video "${criteria}") <(baloosearch -d"$dirPath" "${criteria}" | egrep -i '\.wmv$|\.mkv$'))
}

function runMpv
{
    mpv --shuffle --playlist <(baloosearch -d"$dirPath" -t video "${criteria}")
}

function runMpvOldMethod
{
    baloosearch -d"$dirPath" -t video "${criteria}" | mpv --shuffle --playlist=/dev/fd/3 3<&0 < /dev/tty
}

function mpvHandler
{
    if [ $balooBug -eq 1 ]
    then
        runMpvAndHandlBalooVideoBug
    else
        runMpv
    fi
}

if [ "$viewerName" = "feh" ]
then
    baloosearch -d"$dirPath" -t image "${criteria}" |  feh -F -D $delay -Z -z -Y -f -
elif [ "$viewerName" = "sxiv" ]
then
    baloosearch -d"$dirPath" -t image "${criteria}" | sxiv -a -b -f -i -S $delay -sf
elif [ "$viewerName" = "mpv" ]
then
    mpvHandler
else
    echo "Unsupported viewer $viewerName"
    showUsage
fi
