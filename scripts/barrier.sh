#!/bin/bash
$1 $2'/handshake' &
echo 'ssh' $HOSTNAME 'kill' $! > $2'/pid.txt'
chmod +x $2'/pid.txt'
#echo $! >> $2

