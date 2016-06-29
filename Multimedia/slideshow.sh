#!/bin/bash

#The requirement for this script is baloo and feh and/or sxiv and/or mpv

delay=10
criteria="rating=10"
dirPath="."
viewerName="feh"
balooBug="0"
writeFile="0"
readFile="0"
filePath=""

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
    echo "-i, --input           Read the list of files from images.txt or movies.txt depends on the software. See --software"
    echo "-w, --write           Write the list of files into images.txt or movies.txt depends on the software. See --software"
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
        -i|--input)
            readFile="1"
            shift
            ;;
        -w|--write)
            writeFile="1"
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
    if [ $writeFile -eq 1 ]
    then
        baloosearch -d"$dirPath" -t video "${criteria}" > movies.txt
        exit 0
    elif [ $readFile -eq 1 ]
    then
        mpv --shuffle --playlist=movies.txt
        exit 0
    fi
    
    if [ $balooBug -eq 1 ]
    then
        runMpvAndHandlBalooVideoBug
    else
        runMpv
    fi
}

function sxivHandler
{
    if [ $writeFile -eq 1 ]
    then
        baloosearch -d"$dirPath" -t image "${criteria}" > images.txt
        exit 0
    elif [ $readFile -eq 1 ]
    then
        cat images | sort --random-sort | sxiv -a -b -f -i -S $delay -sf
        exit 0
    fi
    baloosearch -d"$dirPath" -t image "${criteria}" | sort --random-sort | sxiv -a -b -f -i -S $delay -sf
}

function fehHandler
{
    if [ $writeFile -eq 1 ]
    then
        baloosearch -d"$dirPath" -t image "${criteria}" > images.txt
        exit 0
    elif [ $readFile -eq 1 ]
    then
        feh -F -D $delay -Z -z -Y -f images.txt
        exit 0
    fi
    
    baloosearch -d"$dirPath" -t image "${criteria}" |  feh -F -D $delay -Z -z -Y -f -
}

if [ $writeFile -eq 1 ] && [ $readFile -eq 1 ]
then
    echo "You cannot use both read file and write file"
    showUsage
fi

if [ "$viewerName" = "feh" ]
then
    fehHandler
elif [ "$viewerName" = "sxiv" ]
then
    sxivHandler
elif [ "$viewerName" = "mpv" ]
then
    mpvHandler
else
    echo "Unsupported software $viewerName"
    showUsage
fi
