#!/bin/bash
echo "script1 started!"

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

sleep 100

/sbin/m5 checkpoint 0 0


