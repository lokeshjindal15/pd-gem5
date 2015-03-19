#!/bin/bash
echo "tux3 script!"
ifconfig eth0 10.0.0.5
ifconfig lo up
ifconfig eth0 hw ether 00:90:00:00:00:04

sleep 5
