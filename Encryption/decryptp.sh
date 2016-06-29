#!/bin/bash

i="$1"
tarName="$1.tar"

echo "Decrypt file"
gpg -d -o "$tarName" --batch --passphrase-file "${2}/password" "$1"
if [ $? -ne 0 ]
then
    echo "Can't decrypt file"
    exit 1
fi
echo "Delete encrypted file"
rm -f "$i"
if [ $? -ne 0 ]
then
    echo "Can't delete encrypte file"
    exit 1
fi
echo "Extracting tar file"
tar -xf "$tarName" .
if [ $? -ne 0 ]
then
    echo "Can't extracting tar file"
    exit 1
fi
echo "Deleting tar file"
rm -f "$tarName"
if [ $? -ne 0 ]
then
    echo "Can't delete tar file"
    exit 1
fi

echo -e "\n********************\n"


