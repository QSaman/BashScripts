#!/bin/bash
i="$1"

echo -e "\nCreating tar archive"
hashValue="`echo $i | sha1sum | gawk '{print $1}'`"
echo "hashValue: $hashValue"
if [ "$hashValue" = "" ]
then
    echo "Can't hash file"
    exit 1
fi
tarName="t_${hashValue}.tar"
echo "tarName: $tarName"
if [ "$tarName" = "" ]
then
    echo "Can't create tarName"
    exit 1
fi
encryptedName="e_${hashValue}.so_"
echo "encryptedName: $encryptedName"
tar --preserve-permissions --preserve-order -cf "$tarName" "$i"
if [ $? -ne 0 ]
then
    echo "An error occured"
    exit 1
fi
echo "Deleting source file"
rm -rf "$i"
if [ $? -ne 0 ]
then
    echo "Can't delete file"
    exit 1
fi
echo "Encrypt tar file"
gpg --symmetric -o "$encryptedName" --batch --passphrase-file "${2}/password" "$tarName"
if [ $? -ne 0 ]
then
    echo "Error in encryption"
    exit 1
fi
echo "Deleting tar file"
rm -f "$tarName"
echo -e "\n********************\n"
