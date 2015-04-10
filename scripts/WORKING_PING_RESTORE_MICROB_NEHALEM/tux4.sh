#!/bin/bash
echo "tux4 script after restore ping experiment!"

# ifconfig eth0 10.0.0.6
# ifconfig lo up
# ifconfig eth0 hw ether 00:90:00:00:00:05

ifconfig eth0

#/bin/bash 

ping -c 1 10.0.0.2
ping -c 1 10.0.0.3
ping -c 1 10.0.0.4
ping -c 1 10.0.0.5

ping -c 1 10.0.0.2
ping -c 1 10.0.0.3
ping -c 1 10.0.0.4
ping -c 1 10.0.0.5

echo "Now let's spawn 10 threads per core pinging each tux ..."

echo "***** Phase 1 - 20 packets per second*****"
for i in {1..10}
do
   taskset -c 0 ping -i 0.05 -w 0.5 -s 1450 10.0.0.2  &
   #ping -b -i 0.05 -s 1450 10.255.255.255 &
done

for i in {1..10}
do
   taskset -c 1 ping -i 0.05 -w 0.5 -s 1450 10.0.0.3  &
done

for i in {1..10}
do
   taskset -c 2 ping -i 0.05 -w 0.5 -s 1450 10.0.0.4  &
done

for i in {1..10}
do
   taskset -c 3 ping -i 0.05 -w 0.5 -s 1450 10.0.0.5  &
done

sleep 0.6
echo "***** Phase 2 - 1000 packets per second*****"
for i in {1..10}
do
   taskset -c 0 ping -i 0.001 -w 0.5 -s 1450 10.0.0.2  &
   #ping -b -i 0.05 -s 1450 10.255.255.255 &
done

for i in {1..10}
do
   taskset -c 1 ping -i 0.001 -w 0.5 -s 1450 10.0.0.3  &
done

for i in {1..10}
do
   taskset -c 2 ping -i 0.001 -w 0.5 -s 1450 10.0.0.4  &
done

for i in {1..10}
do
   taskset -c 3 ping -i 0.001 -w 0.5 -s 1450 10.0.0.5  &
done

sleep 0.6
echo "***** Phase 3 - 100 packets per second*****"
for i in {1..10}
do
   taskset -c 0 ping -i 0.01 -w 0.5 -s 1450 10.0.0.2  &
   #ping -b -i 0.05 -s 1450 10.255.255.255 &
done

for i in {1..10}
do
   taskset -c 1 ping -i 0.01 -w 0.5 -s 1450 10.0.0.3  &
done

for i in {1..10}
do
   taskset -c 2 ping -i 0.01 -w 0.5 -s 1450 10.0.0.4  &
done

for i in {1..10}
do
   taskset -c 3 ping -i 0.01 -w 0.5 -s 1450 10.0.0.5  &
done

sleep 0.6
echo "***** Phase 4 - 500 packets per second*****"
for i in {1..10}
do
   taskset -c 0 ping -i 0.002 -w 0.5 -s 1450 10.0.0.2  &
   #ping -b -i 0.05 -s 1450 10.255.255.255 &
done

for i in {1..10}
do
   taskset -c 1 ping -i 0.002 -w 0.5 -s 1450 10.0.0.3  &
done

for i in {1..10}
do
   taskset -c 2 ping -i 0.002 -w 0.5 -s 1450 10.0.0.4  &
done

for i in {1..10}
do
   taskset -c 3 ping -i 0.002 -w 0.5 -s 1450 10.0.0.5  &
done

sleep 0.6
echo "***** Phase 5 - 20 packets per second*****"
for i in {1..10}
do
   taskset -c 0 ping -i 0.05 -w 0.5 -s 1450 10.0.0.2  &
   #ping -b -i 0.05 -s 1450 10.255.255.255 &
done

for i in {1..10}
do
   taskset -c 1 ping -i 0.05 -w 0.5 -s 1450 10.0.0.3  &
done

for i in {1..10}
do
   taskset -c 2 ping -i 0.05 -w 0.5 -s 1450 10.0.0.4  &
done

for i in {1..10}
do
   taskset -c 3 ping -i 0.05 -w 0.5 -s 1450 10.0.0.5  &
done

# now sleep to prevent respawning of more pings
sleep 1000

