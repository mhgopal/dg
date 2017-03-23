
#$GI_HOME/bin/ocrconfig -export <file_name>

Shutdown CRS
#crsctl stop crs

#$GI_HOME/crs/install/rootcrs.pl -deconfig -force -verbose as root on all remote nodes:

Final Node: $GI_HOME/crs/install/rootcrs.pl -deconfig -force -verbose -keepdg

GI deinstall tool
#$GI_HOME/deinstall/deinstall

 Reinstall Oracle Grid Infrastructure in new home and run root.sh scripts when prompted

 At this point you could re-import the OCR export to recreate the resources but I opted to re-add by hand using

e

crsctl stop crs
crsctl start crs -excl
crsctl stop resource ora.crsd -init
crsctl -import <file_name>
 SQL> col STATUS format a9
SQL> col hrs format 999.99
SQL> select SESSION_KEY, INPUT_TYPE, STATUS,
 to_char(START_TIME,'mm/dd/yy hh24:mi') start_time,
 to_char(END_TIME,'mm/dd/yy hh24:mi') end_time,
 elapsed_seconds/3600 hrs
 from V$RMAN_BACKUP_JOB_DETAILS
 order by session_key;

SELECT SID, SERIAL#, opname,CONTEXT, SOFAR, TOTALWORK, 
ROUND (SOFAR/TOTALWORK*100, 2) "% COMPLETE"
FROM V$SESSION_LONGOPS
WHERE OPNAME LIKE 'RMAN%' AND TOTALWORK! = 0 AND SOFAR <> TOTALWORK;

