#!/bin/bash

##############
#
#
# This script can be utilized to run against the rman interface.
# rman target / @/tmp/genrman.rcv
# 
#
###############
sqlplus -s "/ as sysdba"<<EOM
SET ECHO OFF
SET FEED OFF
SET TERMOUT OFF
set head off
set linesize 1000
set trimspool on
set pagesize 0
spool /tmp/genrman.rcv
SELECT 'delete '||recid ||';' from v\$backup_piece
where rownum<2 ;
spool off
EOM
