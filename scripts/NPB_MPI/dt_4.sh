#!/bin/bash
/sbin/m5 resetstats
mpirun -np 16 -host  10.0.0.2,10.0.0.3,10.0.0.4,10.0.0.5 /benchmarks/NPB3.3-MPI/bin/dt.S BH
/sbin/m5 exit

