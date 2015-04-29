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
# make sure you rename RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us to a different variable that was not defined
# in the script used to create the first ckpt.
# 2. make sure to check what to use
# /bin/bash for ARM based disk image
# /system/bin/sh for x86 base disk image
# or something else. mount and check your disk image...
# 3. while reading a supplied script and writing to location '/tmp/runscript1.sh'
# use appropriate directory ('tmp').
# again mount and check your disk image...
#################################################################################

# Test if the RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us environment variable is already set
echo "***** Start tux1 ckpt script! *****"
if [ "${RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us+set}" != set ]
then
	# Signal our future self that it's safe to continue
	echo "RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us not set! So setting up network. Then reload self, don't set up network and do this again n again n again n ..."
	export RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us=1
else
	echo "Else part - RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us is set! So reload self and execute!"
	echo "Else part - Loading new script..."
	/sbin/m5 readfile > /tmp/runscript1.sh
	chmod 755 /tmp/runscript1.sh

	# Execute the new runscript
	if [ -s /tmp/runscript1.sh ]
	then
		#/system/bin/sh /data/runscript1.sh
		echo "Else part - executing newly loaded script ..."
		/bin/bash /tmp/runscript1.sh

	else
		echo "Else part - Script not specified. Dropping into shell..."
		echo "Else part - Exiting..."
		/sbin/m5 exit
	fi
fi

#############################################################################
# MODIFY IN THIS SECTION						     	
# Add what you want to do after booting/restoring from a primary checkpoint
# and before taking the desired checkpoint
 
#busybox sleep 600
echo "Setting up network now ..."
echo "1. RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us is $RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us"

ifconfig eth0 10.0.0.3
ifconfig lo up
ifconfig eth0 hw ether 00:90:00:00:00:02

# let's change the sampling period of ondemand governor it would be 40ms currently. Let's make it 20ms.
cd /sys/devices/system/cpu/cpu0/cpufreq
echo "cating cpuinfo_transition_latency ..."
cat cpuinfo_transition_latency
echo "cating ondemand/sampling_rate ..."
cat ondemand/sampling_rate
echo "changing ondemand/sampling_rate ..."
echo $(($(cat cpuinfo_transition_latency) * 500 / 1000)) > ondemand/sampling_rate
echo "cating ondemand/sampling_rate ..."
cat ondemand/sampling_rate

#############################################################################

#THIS IS WHERE EXECUTION BEGINS FROM AFTER RESTORING FROM CKPT CREATED USING THIS SCRIPT
# Test if we previously okayed ourselves to run this script

echo "2. RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us is $RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us"
if [ "$RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us" -eq 1 ]
then

	# Signal our future self not to recurse infinitely
	export RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us=2
	echo "3. RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us is $RUNSCRIPT_VAR_TUX1_WORKING_PING_NPB_CKPT_5NODES_50us"

	# Read the script for the checkpoint restored execution
	echo "Loading new script..."
	/sbin/m5 readfile > /tmp/runscript1.sh
	chmod 755 /tmp/runscript1.sh

	# Execute the new runscript
	if [ -s /tmp/runscript1.sh ]
	then
		#/system/bin/sh /data/runscript1.sh
		echo "executing newly loaded script ..."
		/bin/bash /tmp/runscript1.sh

	else
		echo "Script not specified. Dropping into shell..."
	fi

fi

echo "Fell through script. Exiting..."
/sbin/m5 exit
