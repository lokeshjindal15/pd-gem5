#!/bin/bash

rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
sed 's/TESTNAME/bt_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5000/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
sleep 200 

rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
sed 's/TESTNAME/cg_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5001/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
sleep 200 

rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
sed 's/TESTNAME/dt_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5002/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
sleep 200 

rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
sed 's/TESTNAME/ep_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5003/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
sleep 200 

#rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/ft_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5004/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 

#rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/is_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5005/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 
#
#rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/lu_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5006/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 
#
#rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/mg_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5007/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 
#
#rm -rf L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed 's/TESTNAME/sp_4/g' L20_B80_J1600_nehalem_run_npb.config.ini > L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#sed -i 's/SYNCHPORT/5008/g' L20_B80_J1600_nehalem_run_npb.config.ini.tmp
#python ../../condorDGem5.py L20_B80_J1600_nehalem_run_npb.config.ini.tmp &
#sleep 200 
#
