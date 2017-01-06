set timing on
set echo on

alter session set current_schema=C##SAPR3;

create table SCLVG_TAB ( id number(4), nm varchar2(200), constraint cons_prim primary key ( id) );

---------------------
-- Check table can be redefined
--C##SAPR3 is table name
--SCLVG_TAB is the newtable name
---------------------
EXEC DBMS_REDEFINITION.can_redef_TABle('C##SAPR3', 'SCLVG_TAB');

-- Create new table
CREATE TABLE C##SAPR3.SCLVG_TAB2 AS
SELECT * 
FROM   C##SAPR3.SCLVG_TAB WHERE 1=2;

-- Alter parallelism to desired level for large tables.
ALTER SESSION FORCE PARALLEL DML PARALLEL 8;
ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8;

-- Start Redefinition
EXEC DBMS_REDEFINITION.start_redef_table('C##SAPR3', 'SCLVG_TAB', 'SCLVG_TAB2');

-- Optionally synchronize new table with interim data before index creation
EXEC DBMS_REDEFINITION.sync_interim_table('C##SAPR3', 'SCLVG_TAB', 'SCLVG_TAB2'); 

-- Copy dependents.
SET SERVEROUTPUT ON
DECLARE
  l_num_errors PLS_INTEGER;
BEGIN
  DBMS_REDEFINITION.copy_table_dependents(
    uname               => 'C##SAPR3',
    orig_table          => 'SCLVG_TAB',
    int_table           => 'SCLVG_TAB2',
    copy_indexes        => 1,             -- Default
    copy_triggers       => TRUE,          -- Default
    copy_constraints    => TRUE,          -- Default
    copy_privileges     => TRUE,          -- Default
    ignore_errors       => FALSE,         -- Default
    num_errors          => l_num_errors,
    copy_statistics     => FALSE,         -- Default
    copy_mvlog          => FALSE);        -- Default
    
  DBMS_OUTPUT.put_line('num_errors=' || l_num_errors); 
END;
/
   
-- Complete redefinition
EXEC DBMS_REDEFINITION.finish_redef_TABle('C##SAPR3', 'SCLVG_TAB', 'SCLVG_TAB2');

-- Remove original table which now has the name of the new table DROP TABLE
DROP TABLE C##SAPR3.SCLVG_TAB2;

