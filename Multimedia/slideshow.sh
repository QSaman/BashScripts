#!/bin/bash

#The requirement for this script is baloo and feh and/or sxiv

delay=10
criteria="rating=10"
dirPath="."
viewerName="feh"

function showUsage
{
    echo "Usage:"
    echo "$0 [options]"
    echo "Options:"
    echo "-h, --help:       Show this help"
    echo "-r, --rating:     Minimum rating: e.g. -r 8 means rating>=8. The default is rating=10."
    echo "-c, --criteria:   Criteria: e.g. -c rating=9. The default is rating=10."
    echo "-p, --path:       Path to the root directory to show images. The default is the current directory (.)."
    echo "-d, --delay:      Delay for slideshow. The default is 10s."
    echo "-v, --viewer:     Image viewer. Supported viewer: feh, sxiv"
    echo "                  Note that feh unable to show multiple-frames images like most gifts. On the other hand sxiv can do that."
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
        -v|--viewer)
            viewerName="$2"
            if [ "$viewerName" = "" ]
            then
                showUsage
            fi
            shift 2
            ;;
        *)
            showUsage
            ;;
    esac
done

if [ "$viewerName" = "feh" ]
then
    baloosearch -d"$dirPath" -t image "${criteria}" |  feh -F -D $delay -Z -z -Y -f -
elif [ "$viewerName" = "sxiv" ]
then
    baloosearch -d"$dirPath" -t image "${criteria}" | sxiv -a -b -f -i -S $delay -sf
else
    echo "Unsupported viewer $viewerName"
    showUsage
fi
