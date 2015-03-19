#!/bin/bash
echo "tux2 script!"
ifconfig eth0 10.0.0.4
ifconfig lo up
ifconfig eth0 hw ether 00:90:00:00:00:03

sleep 5
