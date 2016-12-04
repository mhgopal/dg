
Goal
Step by step guide on how to recreate standby control file when datafiles are on ASM and using Oracle Managed Files (OMF)
In case you may want or need more about your current topic - please also access the Data Guard Community of Customers and Oracle Specialists directly via:
https://communities.oracle.com/portal/server.pt/community/high_availability_data_guard/302
Fix
Below are the steps to accomplish the task : 

Step 1: Create the Standby control file on primary database 
Step 2: Copy the controlfile backup to the standby system 
Step 3: Shutdown, restore, rename. 

Example
Step 1 : Create the Standby control file on primary database. 
$ export ORACLE_SID=DEL 
$rman target / 
RMAN> backup current controlfile for standby format 'stdbyctl.bkp'; 
RMAN> EXIT;
stdbyctl.bkp file will be created in "$ORACLE_HOME/dbs" (Unix) or "$ORACLE_HOME/database" (Windows). 

Step 2. Copy the controlfile backup to the standby system 

Using ftp/scp move stdbyctl.bkp to standby system 

Step 3: Shutdown, restore, rename.
A. Shutdown all instances of the standby. 

$ export ORACLE_SID=MUM 
$sqlplus / as sysdba 
SQL> shutdown immediate 
ORA-01109: database not open 


Database dismounted. 
ORACLE instance shut down. 

B. Depending on the location of the logfiles on the standby server remove all online and standby redo logs from the standby directories Using an Operating System utility or ASMCMD and make sure that you have the LOG_FILE_NAME_CONVERT parameter defined to translate any directory paths. 

C. Startup one instance of Standby database in nomount stage: 

$sqlplus / as sysdba 
SQL> startup nomount 
ORACLE instance started. 

Total System Global Area 209715200 bytes 
Fixed Size 1248116 bytes 
Variable Size 75498636 bytes 
Database Buffers 125829120 bytes 
Redo Buffers 7139328 bytes 

D. Connect to RMAN with nocatalog option and Restore the standby control file: 

$rman nocatalog target / 
RMAN> restore standby controlfile from '\tmp\stdbyctl.bkp'; 

Starting restore at 29-AUG-08 
using target database control file instead of recovery catalog 
allocated channel: ORA_DISK_1 
channel ORA_DISK_1: sid=155 devtype=DISK 

channel ORA_DISK_1: restoring control file 
channel ORA_DISK_1: restore complete, elapsed time: 00:00:17 
output filename=+DATA1/del/controlfile/current.257.661096899 
Finished restore at 29-AUG-08 

E. Mount standby database 

RMAN> alter database mount; 

database mounted 

F. Catalog the datafiles of standby database 

Below command will give you a list of files and ask if they should all be catalog. Review the list and say YES if all the datafiles are properly listed 
In below command while cataloging the files, the string specified should refer to the diskgroup/filesystem destination of the standby data files. 

RMAN> catalog start with '+DATA1/MUM/DATAFILE/'; 

Starting implicit crosscheck backup at 29-AUG-08 
using target database control file instead of recovery catalog 
allocated channel: ORA_DISK_1 
channel ORA_DISK_1: sid=155 devtype=DISK 
Crosschecked 10 objects 
Finished implicit crosscheck backup at 29-AUG-08 

Starting implicit crosscheck copy at 29-AUG-08 
using channel ORA_DISK_1 
Finished implicit crosscheck copy at 29-AUG-08 

searching for all files in the recovery area 
cataloging files... 
cataloging done 

List of Cataloged Files 
======================= 
File Name: +fra/MUM/BACKUPSET/2008_07_28/nnndf0_TAG20080728T113319_0.296.661260801 
File Name: +fra/MUM/BACKUPSET/2008_07_28/ncsnf0_TAG20080728T113319_0.297.661260847 
File Name: +fra/MUM/CONTROLFILE/backup.272.661096103 

searching for all files that match the pattern +DATA1/MUM/DATAFILE/ 

List of Files Unknown to the Database 
===================================== 
File Name: +data1/MUM/DATAFILE/SYSTEM.258.661097855 
File Name: +data1/MUM/DATAFILE/SYSAUX.259.661097855 
File Name: +data1/MUM/DATAFILE/UNDOTBS1.260.661097855 
File Name: +data1/MUM/DATAFILE/USERS.261.661097855 

Do you really want to catalog the above files (enter YES or NO)? YES 
cataloging files... 
cataloging done 

List of Cataloged Files 
======================= 
File Name: +data1/MUM/DATAFILE/SYSTEM.258.661097855 
File Name: +data1/MUM/DATAFILE/SYSAUX.259.661097855 
File Name: +data1/MUM/DATAFILE/UNDOTBS1.260.661097855 
File Name: +data1/MUM/DATAFILE/USERS.261.661097855

NOTE: 
a) This will only work if you are using OMF. If you are using ASM without OMF you have to catalog all non-OMF Datafiles as Datafile Copies manually using

RMAN> catalog datafilecopy '';

b) If you have Datafiles on different Diskgroups you have to catalog from all Diskgroups, of course.


G. Commit the changes to the controlfile 

RMAN> switch database to copy; 

datafile 1 switched to datafile copy "+DATA1/mum/datafile/system.258.661097855" 
datafile 2 switched to datafile copy "+DATA1/mum/datafile/undotbs1.260.661097855" 
datafile 3 switched to datafile copy "+DATA1/mum/datafile/sysaux.259.661097855" 
datafile 4 switched to datafile copy "+DATA1/mum/datafile/users.261.661097855" 

RMAN> EXIT; 

H. Re-enable flashback on the standby database. 
$sqlplus / as sysdba 
SQL> alter database flashback off; 

Database altered. 

SQL> alter database flashback on; 

Database altered. 

I. Query v$log and clear all online redo log groups 

SQL> select group# from v$log; 

GROUP# 
---------- 
1 
2 
3 

SQL> alter database clear logfile group 1; 

Database altered. 

SQL> alter database clear logfile group 2; 

Database altered. 

SQL> alter database clear logfile group 3; 

Database altered. 

J. Query v$standby_log and clear all standby redo logs

SQL> select group# from v$standby_log; 

GROUP# 
---------- 
4 
5 
6 

SQL> alter database clear logfile group 4; 

Database altered. 

SQL> alter database clear logfile group 5; 

Database altered. 

SQL> alter database clear logfile group 6; 

Database altered. 

Recreate the standby redo logs on standby database if standby redo logs are not present on the primary.

SQL> select group# from v$standby_log; 

no row selected 

SQL> alter database add standby logfile group 4 size 50m; 

Database altered. 

SQL> alter database add standby logfile group 5 size 50m; 

Database altered. 

SQL> alter database add standby logfile group 6 size 50m; 

Database altered. 

K. Start Managed recovery process on standby 

SQL> alter database recover managed standby database disconnect from session; 

Database altered. 

SQL> exit 
