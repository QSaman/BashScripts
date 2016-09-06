#!/bin/bash

#The requirement for this script is baloo and feh and/or sxiv and/or mpv

delay=10
criteria=""
rating="10"
viewerName="feh"
balooBug="0"
writeFile="0"
linkFiles="0"
readFile="0"
slideshowType="image"
softLinkDir="imageSelection"
fileList="images.txt"
customCriteria=0
uniqueCriteria=0

function showUsage
{
    echo "Usage:"
    echo "$0 [options]"
    echo "Options:"
    echo "-h, --help:               Show this help"
    echo "-r, --rating:             Minimum rating: e.g. -r 8 means rating>=8. The default is rating=10."
    echo "-c, --criteria:           Criteria: e.g. -c rating=9. The default is rating=10. If you use multiple --criteria the result is logical And of all of them."
    echo "-C, --unique-Criteria     Like --criteria but don't consider --rating. In other words, you are responsible for all criteria."
    echo "-p, --path:               Path to the root directory to show images. The default is the current directory (.)."
    echo "                          You can choose multiple --path. In this case, The result is the union of all paths."
    echo "-d, --delay:              Delay for slideshow. The default is 10s."
    echo "                          Note that you can use delay when you've chosen an image viewer."
    echo "-s, --software:           Image viewer or video player." 
    echo "                          Supported image viewers: feh, sxiv"
    echo "                          Note that feh unable to show multiple-frames images like most gifts. On the other hand sxiv can do that."
    echo "                          Supported video players: mpv"
    echo "-b, --bug [type]          Atemporary solutions for some of baloo bugs. type can be the following values"
    echo "                          video: baloo doesn't recognize some vide types like wmv. Use this to temporary solve it."
    echo "                          rating: baloo doesn't handle >= or <= correctly. It only handle = correctly. Use this to solve it."
    echo "-i, --input               Read the list of files from images.txt or movies.txt depends on the software. See --software"
    echo "-w, --write               Write the list of files into images.txt or movies.txt depends on the software. See --software"
    echo "-l, --link [directory]    Generate soft links in directory"
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
            rating="${2}"
            shift 2
            ;;
        -c|--criteria)
            if [ "$criteria" != "" ]
            then
                criteria="(${criteria}) AND (${2})"
            else
                criteria="${2}"
            fi
            customCriteria=1
            if [ "$2" = "" ]
            then
                showUsage
            fi
            shift 2
            ;;
        -C|--unique-criteria)
            uniqueCriteria=1
            criteria="$2"
            if [ "$2" = "" ]
            then
                showUsage
            fi
            shift 2
            ;;
        -p|--path)
            dirPath=("${dirPath[@]}" "$2")
            if [ "$2" = "" ]
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
            if [ "$viewerName" = "mpv" ]
            then
                slideshowType="video"
                fileList="movies.txt"
                softLinkDir="moviesSelection"
            fi
            shift 2
            ;;
        -b|--baloo-bug)
            balooBug="1"
            balooBugType="$2"
            if [ "$balooBugType" != "video" ] && [ "$balooBugType" != "rating" ]
            then
                echo "Unrecognized bug $balooBugType type"
                showUsage
            fi
            shift 2
            ;;
        -i|--input)
            readFile="1"
            shift
            ;;
        -w|--write)
            writeFile="1"
            shift
            ;;
        -l|--link)
            linkFiles="1"
            softLinkDir="$2"
            shift 2
            ;;
        *)
            showUsage
            ;;
    esac
done

function buildBalooCommand
{
    if [ ${#dirPath[@]} -eq 0 ]
    then
        dirPath[0]="."
    fi
    if [ ${#dirPath[@]} -eq 1 ]
    then
        #e.g. baloosearch -d"$dirPath" -t ${slideshowType} "${criteria}" | sed \$d
        balooCommand="baloosearch -d\"${dirPath[0]}\" -t ${slideshowType} \"${criteria}\" | sed \\\$d"
    else
        balooCommand="{"
        for (( i=0; i < ${#dirPath[@]}; ++i ))
        do
            balooCommand="$balooCommand baloosearch -d\"${dirPath[$i]}\" -t ${slideshowType} \"${criteria}\" | sed \\\$d;"
        done
        balooCommand="$balooCommand }"
    fi
    balooCommand="$balooCommand | sort --random-sort --random-source=/dev/random"
}

#At the moment baloo has a bug and doesn't recognize some vide types like wmv. The following function is a temporary solution:
function runMpvAndHandlBalooVideoBug
{
    mpv --shuffle --playlist <(cat <(eval $balooCommand) <(eval $balooCommand | egrep -i '\.wmv$|\.mkv$'))
}

function setCriteira
{
    if [ "${rating}" -ne 0 ]
    then
        if [ "$criteria" != "" ]
        then
            criteria="(${criteria}) AND ("
        else
            criteria="("
        fi
        if [ $balooBug -eq 1 ] && [ "$balooBugType" = "rating" ]
        then    
            local first=1
            for (( i=${rating}; i<=10; i++ ))
            do
                if [ $first -eq 1 ]
                then
                    first=0
                else
                    criteria="$criteria OR "
                fi
                criteria="${criteria}rating=${i}"
            done
            criteria="${criteria})"
        else
            criteria="${criteria}rating>=${rating})"
        fi
    fi
    echo "criteria: \"${criteria}\""
}

function runMpv
{
    mpv --shuffle --playlist <(eval $balooCommand)
}

function runMpvOldMethod
{
    eval $balooCommand | mpv --shuffle --playlist=/dev/fd/3 3<&0 < /dev/tty
}

function mpvHandler
{
    if [ $readFile -eq 1 ]
    then
        mpv --shuffle --playlist=movies.txt
        exit 0
    fi
    
    if [ $balooBug -eq 1 ] && [ "$balooBugType" = "video" ]
    then
        runMpvAndHandlBalooVideoBug
    else
        runMpv
    fi
}

function sxivHandler
{
    if [ $readFile -eq 1 ]
    then
        cat images.txt | sort --random-sort | sxiv -a -b -f -i -S $delay -sf
        exit 0
    fi
    eval $balooCommand | sort --random-sort | sxiv -a -b -f -i -S $delay -sf
}

function fehHandler
{
    if [ $readFile -eq 1 ]
    then
        feh -F -D $delay -Z -z -Y -f images.txt
        exit 0
    fi

    eval $balooCommand |  feh -F -D $delay -Z -z -Y -f -
}

function checkGenerateFileList
{
    if [ $writeFile -eq 1 ]
    then
        #By realpath I convert absolute path to relative path
        #xargs can handle whitespaces in file name but it requires all paths are null-terminated so I've used tr '\n' '\0'
        #sed \$d remove the last line which is elapsed time by baloosearch
        #You can also use the following command but the former is prefered:
        #eval $balooCommand | xargs -d '\n' realpath --relative-to="`pwd`" > "$fileList"
        eval $balooCommand | tr '\n' '\0' | xargs -0 realpath --relative-to="`pwd`" > "$fileList"
        exit 0
    fi
}

function checkGeneratingSoftLinks
{
    if [ $linkFiles -eq 1 ]
    then
        mkdir "$softLinkDir"
        if [ $? -ne 0 ]
        then
            echo "Problem in making $softLinkDir. I don't have write permission or directory exist"
            exit 1
        fi
        #eval $balooCommand | tr '\n' '\0' | xargs -0 realpath --relative-to="`pwd`${softLinkDir}" | tr '\n' '\0' | xargs -0 -I target ln -s target ${softLinkDir}
        eval $balooCommand | tr '\n' '\0' | xargs -0 ln -s -r --backup=numbered -t "${softLinkDir}"
        oldIFS="$IFS"
        IFS=$'\n'
        for i in $(find -L "${softLinkDir}" -type f -iname '*~')
        do            
            filename=$(basename "$i")
            number="${filename##*.}"
            number="${number:1:${#number} - 2}"
            filename="${filename%.*}"
            extension="${filename##*.}"
            filename="${filename%.*}"
            filename="${filename}-${number}.${extension}"            
            mv "$i" "${softLinkDir}/$filename"
        done
        IFS="$oldIFS"        
        exit 0
    fi
}

if [ $writeFile -eq 1 ] && [ $readFile -eq 1 ]
then
    echo "You cannot use both read file and write file"
    showUsage
fi

if [ $uniqueCriteria -ne 1 ]
then
    setCriteira
fi


buildBalooCommand

checkGenerateFileList
checkGeneratingSoftLinks

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
