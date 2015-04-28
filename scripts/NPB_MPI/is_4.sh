#!/bin/bash
/sbin/m5 resetstats

# 1000 => @ 1000*1000 ticks start dumping and 10000000 => after ticks 10000000*1000 dump regularly i.e. 100 times a second
/sbin/m5 dumpresetstats 1000 10000000
mpirun -np 16 -host  10.0.0.2,10.0.0.3,10.0.0.4,10.0.0.5 /benchmarks/NPB3.3-MPI/bin/is.S.16
/sbin/m5 exit

