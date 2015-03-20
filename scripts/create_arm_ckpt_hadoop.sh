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
# Author:
#   Joel Hestness, hestness@cs.utexas.edu
#   while at AMD Research and Advanced Development Lab
# Date:
#   10/5/2010
#

# Test if the RUNSCRIPT_VAR environment variable is already set
echo "I am inside create_arm_ckpt_hadoop.sh!"
echo "Test m5"
if [ "${RUNSCRIPT_VAR+set}" != set ]
then
	# Signal our future self that it's safe to continue
	echo "RUNSCRIPT_VAR not set! So setting it and taking checkpoint!"
	export RUNSCRIPT_VAR=1
else
	# We've already executed once, so we should exit
	echo "calling m5 exit!"
	/sbin/m5 exit
fi

#busybox sleep 600
echo "script1 started!"
echo "1. RUNSCRIPT_VAR is $RUNSCRIPT_VAR"
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

echo "start mapred"
$HADOOP_HOME/bin/start-mapred.sh
echo "mapred started"

#wait 5 min for hadoop to brings up
sleep 300

# Checkpoint the first execution
echo "Checkpointing simulation..."
/sbin/m5 checkpoint 0 0


echo "2. RUNSCRIPT_VAR is $RUNSCRIPT_VAR"
#THIS IS WHERE EXECUTION BEGINS FROM AFTER RESTORING FROM CKPT CREATED USING THIS SCRIPT
# Test if we previously okayed ourselves to run this script
if [ "$RUNSCRIPT_VAR" -eq 1 ]
then

	# Signal our future self not to recurse infinitely
	export RUNSCRIPT_VAR=2

	echo "3. RUNSCRIPT_VAR is $RUNSCRIPT_VAR"
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
