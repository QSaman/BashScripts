#!/bin/bash

path="`date +%F`"
fileExt="ogg"
fileName="`date +%H-%M-%S`.$fileExt"

mkdir -p "$path"
if [ $? -ne 0 ]
then
    exit 1
fi
rec -c 1 "${path}/${fileName}"
