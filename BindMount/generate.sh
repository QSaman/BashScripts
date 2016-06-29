#!/bin/bash

sourcePath="/run/media/user/Remoable/Old"
intermediatePath="/home/user/foo/bar"
targetPath="/run/media/user/Remoable/New"
targetDirName="Docs"
prefixOutput="foo/bar"
fileName="result.txt"

function findDirectoryNames
{
  pushd "$sourcePath" > /dev/null
  OLDIFS=$IFS
  IFS=$'\n'
  sourceArray=($(find -mindepth 1 -maxdepth 1 -type d))
  IFS=$OLDIFS
  popd > /dev/null
}

echo "" > "$fileName"
if [ $? -ne 0 ]
then
  exit 1
fi

findDirectoryNames

for ((i = 0; i < ${#sourceArray[@]}; ++i))
do
  srDirName="${sourceArray[$i]}"
  srDirName="${srDirName:2}" #Remove ./ from beginning of string
  intermediateDir="${intermediatePath}/${srDirName}/${targetDirName}"
  
  stat "$intermediateDir" > /dev/null
  if [ $? -ne 0 ]
  then
    echo "$intermediateDir does not exist"
    exit 1
  fi
  
  targetDir="${targetPath}/${srDirName}/${targetDirName}"  
  echo "Creating $targetDir"
  mkdir -p "$targetDir"
  if [ $? -ne 0 ]
  then
    exit 1
  fi
  
  srcDir="${sourcePath}/${srDirName}"
  echo "Move $srcDir contents to $targetDir"
  mv -T "$srcDir" "$targetDir"
  if [ $? -ne 0 ]
  then
    exit 1
  fi
  echo "${prefixOutput}/${srDirName}/${targetDirName}" >> "$fileName"
done