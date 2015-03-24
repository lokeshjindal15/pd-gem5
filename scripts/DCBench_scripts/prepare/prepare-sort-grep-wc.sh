#!/bin/bash

export JAVA_HOME=/root/jdk1.7.0_60
export HADOOP_HOME=/root/hadoop-1.0.2
export HIVE_HOME=/root/apache-hive-0.13.1-bin
export MAHOUT_HOME=/root/mahout-distribution-0.6


cd /benchmarks/DCBench/workloads/base-operations/grep
./prepare-grep.sh 120MB


/sbin/m5 checkpoint 0 0

