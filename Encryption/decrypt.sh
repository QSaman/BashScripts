#!/bin/bash

if [ "$1" = "" ]
then
    echo "No input parameters"
    exit 1
fi

srcDir=$1
cnt=1
curPwd="`pwd`"
cd "$srcDir"
if [ $? -ne 0 ]
then
    echo "source directory is unreachalbe"
    exit 1
fi
find -type f -iname "*.so_" -print0 -exec "${curPwd}/decryptp.sh" '{}' "$curPwd" \;

