#!/bin/bash
echo "script1 started!"

ifconfig eth0 10.0.0.2
ifconfig lo up
ifconfig eth0 hw ether 00:90:00:00:00:01

export JAVA_HOME=/root/jdk1.7.0_60
export HADOOP_HOME=/root/hadoop-1.0.2
export HIVE_HOME=/root/apache-hive-0.13.1-bin
export MAHOUT_HOME=/root/mahout-distribution-0.6

$HADOOP_HOME/bin/hadoop namenode -format <<< $"Y"

echo "start dfs"
$HADOOP_HOME/bin/start-dfs.sh
echo "dfs started"

sleep 10

/sbin/m5 checkpoint 0 0

echo "start mapred"
$HADOOP_HOME/bin/start-mapred.sh
echo "mapred started"

#wait 5 min for hadoop to brings up
sleep 300

/sbin/m5 checkpoint 0 0


