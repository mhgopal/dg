DUPLICATE TARGET DATABASE
  FOR STANDBY
  DORECOVER
  SPFILE
parameter_value_convert 'DBATOOLS','STTOOLS'
SET DB_UNIQUE_NAME='STTOOLS'
set instance_number='1'
    SET DB_FILE_NAME_CONVERT='+DATA/DBATOOLS/','+DATA/STTOOLS/'
    SET LOG_FILE_NAME_CONVERT='+DATA/DBATOOLS/','+DATA/STTOOLS/'
  NOFILENAMECHECK;


--note the case
DUPLICATE TARGET DATABASE
  FOR STANDBY from active database
  DORECOVER
  SPFILE
parameter_value_convert 'SPRD','CPRD'
SET DB_UNIQUE_NAME='CPRD'
set instance_number='1'
    SET DB_FILE_NAME_CONVERT='+DATA/SPRD/','+DATA/CPRD/'
    SET LOG_FILE_NAME_CONVERT='+DATA/SPRD/','+DATA/CPRD/'
  NOFILENAMECHECK;
 
