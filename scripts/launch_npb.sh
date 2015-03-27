#!/bin/bash

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/bt_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5000/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee bt_4.log &
sleep 200 

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/cg_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5001/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee cg_4.log &
sleep 200 

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/dt_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5002/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee dt_4.log &
sleep 200 

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/ep_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5003/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee ep_4.log &
sleep 200 

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/ft_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5004/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee ft_4.log &
sleep 200 

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/is_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5005/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee is_4.log &
sleep 200 

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/lu_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5006/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee lu_4.log &
sleep 200 

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/mg_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5007/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee mg_4.log &
sleep 200 

rm -rf run_npb.config.ini.tmp
sed 's/TESTNAME/sp_4/g' run_npb.config.ini > run_npb.config.ini.tmp
sed -i 's/SYNCHPORT/5008/g' run_npb.config.ini.tmp
python condorDGem5.py run_npb.config.ini.tmp |& tee sp_4.log &
sleep 200 

