#!/bin/bash
echo "tux4 script!"
ifconfig eth0 10.0.0.6
ifconfig lo up
ifconfig eth0 hw ether 00:90:00:00:00:05

sleep 5
