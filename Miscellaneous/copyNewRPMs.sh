#!/bin/bash


function normalizeDirectory
{
    local res="$1"
    if [ "${res: -1}" != "/" ]
    then
        res="${res}/"
    fi
    echo "$res"
}

if [ $# -ne 3 ] && [ $# -ne 2 ]
then
    echo "[first directory] [second directory]"
    echo "first directory] [second directory] [target directory]"
    echo "Note that when the script is provided with three arguments, [second directory] will be updated"
    exit 0
fi

firstDir="$1"
secondDir="$2"
targetDir="$3"

firstDir="`normalizeDirectory "$firstDir"`"
secondDir="`normalizeDirectory "$secondDir"`"

res=`rsync --dry-run -i -a "$firstDir" "$secondDir" | grep -E '^>|^<' | grep -iE "\.rpm$" | cut -c13-`
if [ $? -ne 0 ]
then
    exit 1
fi

echo "*******************************************"
echo "$res"
echo "*******************************************"
if [ $# -eq 2 ]
then
    exit 0
fi
echo "Creating $targetDir (if not exists)"
mkdir -p "$targetDir"
if [ $? -ne 0 ]
then
    exit 1
fi
OLDIFS=$IFS
IFS=$'\n'
for i in $res
do
    srcFile="${firstDir}${i}"
    echo "Copying $i to $targetDir"
    cp -a "$srcFile" "$targetDir"
    if [ $? -ne 0 ]
    then
        exit 2
    fi
    echo "Copying $i to $secondDir"
    cp -a "$srcFile" "$secondDir"
    if [ $? -ne 0 ]
    then
        exit 3
    fi
done
IFS=$OLDIFS
