1.- Create staging table to store the SQL Profiles to be copied on Source database:

MYUSER@MYDB> EXEC DBMS_SQLTUNE.CREATE_STGTAB_SQLPROF (table_name => 'PROFILE_STGTAB');

2.- Copy SQL Profiles from SYS to the staging table:

MYUSER@MYDB> EXEC DBMS_SQLTUNE.PACK_STGTAB_SQLPROF (profile_category => '%', staging_table_name => 'PROFILE_STGTAB');

As I needed to copy all SQL Profiles on my database ‘%’ value for profile_category was the best option.

3.- Export staging table.

4.- Create staging table on Destination Database:

MYUSER@MYDB> EXEC DBMS_SQLTUNE.CREATE_STGTAB_SQLPROF (table_name => 'PROFILE_STGTAB');

5.- Import data on Destination database.

6.- Create SQL Profiles on Destination database using data stored on staging table:

MYUSER@MYDB> EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLPROF(replace => TRUE, staging_table_name => 'PROFILE_STGTAB');
