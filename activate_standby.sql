SQL> alter database recover managed standby database finish;
alter database recover managed standby database finish
*
ERROR at line 1:
ORA-00283: recovery session canceled due to errors
ORA-16157: media recovery not allowed following successful FINISH recovery


SQL> alter database activate physical standby database;

Database altered.

SQL> alter database open;

Database altered.

SQL> select name, open_mode, database_role from v$database;

NAME      OPEN_MODE            DATABASE_ROLE
--------- -------------------- ----------------
SPRD      READ WRITE           PRIMARY

SQL>

