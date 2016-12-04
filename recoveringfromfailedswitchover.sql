Recovering from a Failed DG Broker Switchover
 
Problem Description
Should you find yourself in a situation where a Data Guard Broker switchover to Standby has failed and left your environment with 2 Physical Standby Databases, follow this simple procedure to switch the failed switchover Standby Database back to Primary.
 
You may also see the following error from a DGMGRL "show configuration" command:
 
ORA-16816: incorrect database role
 
Solution
 
1.       Logon (as sysdba) to the instance that was your Primary database instance before the switchover.

2.       Confirm the database role.
SQL> select database_role from v$database;
 
DATABASE_ROLE
----------------
PHYSICAL STANDBY
 
3.       Shutdown the instance.
SQL> shutdown immediate;

4.       Mount the database.
SQL> startup mount;

5.       Cancel the MRP process. You will receive “ORA-16136: Managed Standby Recovery not active” if it is not running, but you can ignore.
SQL> alter database recover managed standby database cancel;

6.       Terminate the current switchover to Standby that never completed fully.  
SQL> alter database recover managed standby database finish;

7.       Now switchover to Primary.
SQL> alter database commit to switchover to primary with session shutdown;

8.       Open the database.
SQL> alter database open;

9.       Confirm the database role.
SQL> select database_role from v$database;
 
DATABASE_ROLE
----------------
PRIMARY

Additional Steps
When attempting to open the Primary Database you may suffer the following error:
 
SQL> alter database open
*
ERROR at line 1:
ORA-16649: possible failover to another database prevents this database being opened
 
In this case, before you can open the database, you must disable Data Guard Broker as follows:
 
SQL> alter system set dg_broker_start=false scope=both sid=’*’;
 
System altered.
 
SQL> alter database open;
 
Database altered.
 
Now re-install Data Guard Broker.
