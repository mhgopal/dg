Step 1: Create export or import parameter file
$ cat exp.par
userid=sthomas/tiger
job_name=tab_export
directory=EXP_DIR
dumpfile=TST_table_exp.dmp
logfile=TST_tab_exp.log
REUSE_DUMPFILES=y
tables=sox.PROFILE,sox.PROFIL_ACC_TYPE,sox.PURCHASE_STEP,sox.RULE,sox.SUB,sox.SUB_TABLE,sox.TIME_PERIOD 

Step 2: Create a shell script which calls the expdp in nohup and change the permission to executable.
$ cat export.sh
nohup expdp parfile=/home/oracle/st/exp.par &
$ chmod 744 export.sh

Step 3: run the shell script in nohup. This will release the prompt immediately and there will not be any running job in the prompt. You can see the datapump job running in DBA_DATAPUMP_JOBS view.
$ nohup export.sh &

[1] 30221

$ nohup: appending output to `nohup.out'
