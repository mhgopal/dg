select OWNER, TABLE_NAME, LAST_ANALYZED from dba_tab_statistics where table_name='X$KGLDP';




OWNER          TABLE_NAME        LAST_ANAL
------------------------------ ------------------------------      ---------
SYS                     X$KGLDP         20-MAR-12


Secondly Export the current fixed stats in a table: (in case you need to revert back)

exec dbms_stats.create_stat_table('OWNER','STATS_TABLE_NAME','TABLESPACE_NAME');
exec dbms_stats.export_fixed_objects_stats(stattab=>'STATS_TABLE_NAME',statown=>'OWNER');

Thirdly Gather fixed objects stats:


exec dbms_stats.gather_fixed_objects_stats;


In case of reverting to the old statistics:
In case you experianced a bad performance on fixed tables after gathering the new statistics:

exec dbms_stats.delete_fixed_objects_stats(); 
exec DBMS_STATS.import_fixed_objects_stats(stattab =>’STATS_TABLE_NAME’,STATOWN =>'OWNER');
