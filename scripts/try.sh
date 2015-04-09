#!/bin/bash

echo "hello" > try.log

#condor                                                                                                                                                           
export CONDOR_CONFIG="/mnt/condor/etc/condor_config"
export PATH="/mnt/condor/bin:/mnt/condor/sbin:$PATH"

export PATH="$PATH:/condor/bin"

#which condor_q

condor_q | grep ljindal | wc -l

