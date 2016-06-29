#!/bin/bash

mediaRoot="/run/media/user/Removable"
localRoot="/home/user/foo"
mountPoint="Removable01"

mountDirs=("foo/bar/baz1"
	   "foo/bar/baz2")


if [ $# -ne 1 ]
then
  echo "You must enter one argument. Ussage: mount [bind/unbind]"
  exit 0
fi

function bindDirs
{
  for ((i = 0; i < ${#mountDirs[@]}; ++i))
  do
    myDir=${mountDirs[$i]}
    targetDir="${localRoot}/${myDir}/${mountPoint}"
    sourceDir="${mediaRoot}/${myDir}"
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
  done
}

function unbindDirs
{
  for ((i = 0; i < ${#mountDirs[@]}; ++i ))
  do
    myDir=${mountDirs[$i]}
    targetDir="${localRoot}/${myDir}/${mountPoint}"
    echo "Unmounting $targetDir"
    sudo umount "${targetDir}"
    if [ $? -ne 0 ]
    then
      exit 1
    fi    
  done
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
  
  