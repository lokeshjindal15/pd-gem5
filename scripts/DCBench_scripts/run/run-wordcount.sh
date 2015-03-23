#!/bin/bash

export JAVA_HOME=/root/jdk1.7.0_60
export HADOOP_HOME=/root/hadoop-1.0.2
export HIVE_HOME=/root/apache-hive-0.13.1-bin
export MAHOUT_HOME=/root/mahout-distribution-0.6

# if we annotate benchmarks with magic instructions, then "m5 resetstats" & "m5 exit" are unnecessary
/sbin/m5 resetstats

cd /benchmarks/DCBench/workloads/base-operations/wordcount
./run-wordcount.sh 100MB

/sbin/m5 exit


