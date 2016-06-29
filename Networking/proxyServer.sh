#!/bin/bash

localPort="12345"
server="60.1.3.9"
serverPort="7779"
pipeName="pipe"
netcatCmd="netcat"
logFile="proxy.log"

rm -rf "$pipeName"
if [ $? -ne 0 ]
then
    echo "Cannot rm $pipeName"
    exit 1
fi
mkfifo "$pipeName"
if [ $? -ne 0 ]
then
    echo "Cannot create fifo: $pipeName"    
    exit 1
fi

echo "" > "$logFile"
if [ $? -ne 0 ]
then
    echo "Cannot create or empty $logFile"
    exit 1
fi

#If we simplify below command:
#mkfifo pipe
#nc -l -p 12345 < pipe | nc server 12346 | tee pipe 

"$netcatCmd" -v -l -p $localPort < "$pipeName" | tee -a "$logFile" | "$netcatCmd" -v $server $serverPort | tee -a "$logFile" | tee "$pipeName"
