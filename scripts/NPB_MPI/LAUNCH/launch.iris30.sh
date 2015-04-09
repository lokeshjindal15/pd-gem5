#!/bin/bash

#rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/bt_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5000/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 
#
#rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/cg_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5001/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 
#
#rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/dt_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5002/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 
#
#rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/ep_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5003/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 
#
rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
sed 's/TESTNAME/ft_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5004/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
sleep 200 

rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
sed 's/TESTNAME/is_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5005/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
sleep 200 

#rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/lu_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5006/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 

rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
sed 's/TESTNAME/mg_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5007/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
sleep 200 

rm -rf L40_B160_J1600_nehalem_run_npb.config.ini.tmp
sed 's/TESTNAME/sp_4/g' L40_B160_J1600_nehalem_run_npb.config.ini > L40_B160_J1600_nehalem_run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5008/g' L40_B160_J1600_nehalem_run_npb.config.ini.tmp
python ../../condorDGem5.py L40_B160_J1600_nehalem_run_npb.config.ini.tmp &
sleep 200 
#
