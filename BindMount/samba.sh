#!/bin/bash

sourceRoot="/path/to/source"
targetRoot="/path/to/samba_directory"
mountPoint="directory_name"

if [ $# -ne 1 ]
then
  echo "You must enter one argument. Ussage: mount [bind/unbind]"
  exit 0
fi

function bindDirs
{
    targetDir="${targetRoot}/${mountPoint}"
    sourceDir="${sourceRoot}"
    echo "Granting SELinux permission for Samba"
    chcon -R -t samba_share_t "${sourceDir}"
    echo "Creating if not exist $targetDir"
    mkdir -p "$targetDir"
    if [ $? -ne 0 ]
    then
        exit 1
    fi
    echo "Mounting $sourceDir to $targetDir"
    sudo mount --bind  "${sourceDir}" "${targetDir}"
    if [ $? -ne 0 ]
    then
        exit 1
    fi    
    echo "Checking Samba daemon status"
    sudo systemctl status smb.service &> /dev/null
    if [ $? -ne 0 ]
    then
        echo "Samba daemon is not running. Try to start daemon"
        sudo systemctl start smb.service &> /dev/null
        if [ $? -ne 0 ]
        then
            echo "Cannot start Samba daemon"
        fi
    else
        echo "Samba daemon is running"
    fi    
}

function unbindDirs
{
    targetDir="${targetRoot}/${mountPoint}"
    echo "Unmounting $targetDir"
    sudo umount "${targetDir}"
    if [ $? -ne 0 ]
    then
      exit 1
    fi    
}

if [ "$1" = "bind" ]
then
  bindDirs
elif [ "$1" = "unbind" ]
then
  unbindDirs
else
  echo "Invalid argument $1"
  exit 2
fi
  
  
