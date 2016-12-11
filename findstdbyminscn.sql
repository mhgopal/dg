SQL> SELECT CURRENT_SCN FROM V$DATABASE;

CURRENT_SCN
--------------
3164433 

SQL> select min(fhscn) from x$kcvfh;

MIN(FHSCN)
----------------
3162298

SQL> select min(f.fhscn) from x$kcvfh f, v$datafile d
      where f.hxfil =d.file#
        and d.enabled != 'READ ONLY'     ;

MIN(F.FHSCN)
----------------
3162298
3. You need to use the ‘lowest SCN‘ from the the 3 queries, which here is -> SCN: 3162298. In RMAN, connect to the PRIMARY database and create an incremental backup from the SCN derived in the previous step:
