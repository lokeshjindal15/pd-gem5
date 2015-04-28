#!/bin/bash

# ******************************
# Author:
# Lokesh Jindal
# April 2015
# lokeshjindal15@cs.wisc.edu
# ******************************

# Description:
# This script checks how many gem5 sims have finished gracefully ("m5_exit")
# and how many NPB benchmarks have complete gracefully ("benchmark completed")
# It then checks that both should be equal
# Further, it checks how many condor jobs are still running
# and then checks if the number of jobs running/completed satisy the constraints

# Usage: ./condor_sim_staus.sh rundir/NEHALEM_NPB_L10_B160_J1600/ 45 1 iris-21 iris-22
# This script takes 5 arguments:
# 1. directory which contains subdirectories of different benchmark runs
# 2. number of condor jobs initially launched - used to satisy the checks
# 3. should use both machines (1) or only the first one (0)
# 4. condor_machine 1
# 5. condor machine 2

# This script also uses another script called try.sh whose contents are listed at the end of this script

# Tip: You might want to 
# change the username in try.sh
# change the strings used to grep completion of graceful exit of gem5
# change the strings used to grep graceful completion of benchmakrs
# number of condor_jobs per benchmark 5 in our case

CONDOR_JOBS_PER_BMARK=6
echo "condor_jobs per benchmark = $CONDOR_JOBS_PER_BMARK"

directory=$1
launched_cond_jobs=$2
use_machine2=$3
condor_machine1=$4

cwd=`pwd`

cd $directory

echo "running check_sim_status in dir $directory ..."

find . -name gem5sim.out | xargs grep 'Exiting @ tick.*because m5_exit instruction encountered'
num_exits=`find . -name gem5sim.out | xargs grep 'Exiting @ tick.*because m5_exit instruction encountered' | wc -l`

find . -name system.terminal | xargs grep -i '.. benchmark.*completed'
bcmplts=`find . -name system.terminal | xargs grep -i '.. benchmark.*completed' | wc -l`

echo "num_exits=$num_exits and bcmplts=$bcmplts"

if [ "$num_exits" != "$bcmplts" ]
then
	echo "*****DANGER num_exits=$num_exits NOT EQUAL TO bcmplts=$bcmplts *****"
else
	echo "num_exits=$num_exits equals bcmplts=$bcmplts"
fi

cd $cwd

echo "running condor_q on $condor_machine1 ..."
jobs_running1=$(ssh $condor_machine1 'bash -s' < try.sh)

if [ "$use_machine2" == 1 ]
then
	condor_machine2=$5
	echo "running condor_q on $condor_machine2 ..."
	jobs_running2=$(ssh $condor_machine2 'bash -s' < try.sh)
else
	echo "Warn: using only 1 condor machine"
	jobs_running2=0
fi

echo "jobs_running1=$jobs_running1"
echo "jobs_running2=$jobs_running2"

jobs_running=$(($jobs_running1 + $jobs_running2))

exp_jobs=$(($launched_cond_jobs - $(($bcmplts * $CONDOR_JOBS_PER_BMARK))))

if [ "$jobs_running" != "$exp_jobs" ]
then
	echo "*****DANGER jobs_running=$jobs_running NOT EQUAL TO exp_jobs=$exp_jobs *****"
else
	echo "jobs_running=$jobs_running equals exp_jobs=$exp_jobs"
	echo "Things seem fine!"
fi

echo "done!"

###################################################################################################
# contents of try.sh
# ##################
# # !/bin/bash
# 
# echo "hello" > try.log
# 
# #condor                                                                                                                                                           
# export CONDOR_CONFIG="/mnt/condor/etc/condor_config"
# export PATH="/mnt/condor/bin:/mnt/condor/sbin:$PATH"
# 
# export PATH="$PATH:/condor/bin"
# 
# #which condor_q
# 
# condor_q | grep ljindal | wc -l
####################################################################################################
