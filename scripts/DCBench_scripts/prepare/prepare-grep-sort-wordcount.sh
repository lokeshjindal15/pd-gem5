#!/bin/bash

# lokeshjindal15
# use /system/bin/sh with Asimbench disk image
# use /bin/bash with arm_ubuntu_natty_headless disk image

#
# This is a tricky script to understand. When run in M5, it creates
# a checkpoint after Linux boot up, but before any benchmarks have
# been run. By playing around with environment variables, we can
# detect whether the checkpoint has been taken.
#  - If the checkpoint hasn't been taken, the script allows M5 to checkpoint the system,
# re-read this script into a new tmp file, and re-run it. On the
# second execution of this script (checkpoint has been taken), the
# environment variable is already set, so the script will exit the
# simulation
#  - When we restore the simulation from a checkpoint, we can
# specify a new script for M5 to execute in the full-system simulation,
# and it will be executed as if a checkpoint had just been taken.
#
# Original Author:
#   Joel Hestness, hestness@cs.utexas.edu
#   while at AMD Research and Advanced Development Lab
# Date:
#   10/5/2010
#
#*********************************
# Modified by:
# Lokesh Jindal
# March, 2015
# lokeshjindal15@cs.wisc.edu
#*********************************

#################################################################################
# Tips:
# 1. If restoring from a previous ckpt created using this script and 
# want to create a second ckpt using this script,
# make sure you rename RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT to a different variable that was not defined
# in the script used to create the first ckpt.
# 2. make sure to check what to use
# /bin/bash for ARM based disk image
# /system/bin/sh for x86 base disk image
# or something else. mount and check your disk image...
# 3. while reading a supplied script and writing to location '/tmp/runscript.sh'
# use appropriate directory ('tmp').
# again mount and check your disk image...
#################################################################################

echo "I am inside prepare-grep-sort-wordcount.sh!"
# Test if the RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT environment variable is already set
echo "Test m5"
if [ "${RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT+set}" != set ]
then
	# Signal our future self that it's safe to continue
	echo "RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT not set! So setting it and taking checkpoint!"
	export RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT=1
else
	# We've already executed once, so we should exit
	echo "calling m5 exit!"
	/sbin/m5 exit
fi

#############################################################################
# MODIFY IN THIS SECTION						     	
# Add what you want to do after booting/restoring from a primary checkpoint
# and before taking the desired checkpoint
 
#busybox sleep 600
echo "Acting after boot/restoring from primary ckpt"
echo "1. RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT is $RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT"

ifconfig eth0 10.0.0.2
ifconfig lo up
ifconfig eth0 hw ether 00:90:00:00:00:01

export JAVA_HOME=/root/jdk1.7.0_60
export HADOOP_HOME=/root/hadoop-1.0.2
export HIVE_HOME=/root/apache-hive-0.13.1-bin
export MAHOUT_HOME=/root/mahout-distribution-0.6

echo "************ Launching prepare-grep ***********"
cd /benchmarks/DCBench/workloads/base-operations/grep
./prepare-grep.sh 120MB
echo "************ done with prepare-grep ***********"

#echo "************ Launching prepare-sort ***********"
#cd /benchmarks/DCBench/workloads/base-operations/sort
#./prepare-sort.sh 100MB
#echo "************ done with prepare-sort ***********"
#
#echo "************ Launching prepare-wordcount ***********"
#cd /benchmarks/DCBench/workloads/base-operations/wordcount
#./prepare-wordcount.sh 100MB
#echo "************ done with prepare-wordcount ***********"

echo "************ Actually done with all 3 grep-sort-wordcount since using new tux0.img***********"
echo "Doing ls on distributed file system..."
$HADOOP_HOME/bin/hadoop dfs -ls /cloudrank-data/
echo "*********************************************************************************************"

# Checkpoint the first execution
echo "Checkpointing simulation..."
/sbin/m5 checkpoint 0 0
#############################################################################

#THIS IS WHERE EXECUTION BEGINS FROM AFTER RESTORING FROM CKPT CREATED USING THIS SCRIPT
# Test if we previously okayed ourselves to run this script

echo "2. RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT is $RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT"
if [ "$RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT" -eq 1 ]
then

	# Signal our future self not to recurse infinitely
	export RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT=2
	echo "3. RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT is $RUNSCRIPT_VAR_GREP_SORT_WORDCOUNT"

	# Read the script for the checkpoint restored execution
	echo "Loading new script..."
	/sbin/m5 readfile > /tmp/runscript.sh
	chmod 755 /tmp/runscript.sh

	# Execute the new runscript
	if [ -s /tmp/runscript.sh ]
	then
		#/system/bin/sh /data/runscript.sh
		echo "executing newly loaded script"
		/bin/bash /tmp/runscript.sh

	else
		echo "Script not specified. Dropping into shell..."
	fi

fi

echo "Fell through script. Exiting..."
/sbin/m5 exit
