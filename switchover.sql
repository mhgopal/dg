Database Switchover

A database can be in one of two mutually exclusive modes (primary or standby). These roles can be altered at runtime without loss of data or resetting of redo logs. This process is known as a Switchover and can be performed using the following statements.

-- Convert primary database to standby
CONNECT / AS SYSDBA
ALTER DATABASE COMMIT TO SWITCHOVER TO STANDBY;

-- Shutdown primary database
SHUTDOWN IMMEDIATE;

-- Mount old primary database as standby database
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
On the original standby database issue the following commands.

-- Convert standby database to primary
CONNECT / AS SYSDBA
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;

-- Shutdown standby database
SHUTDOWN IMMEDIATE;

-- Open old standby database as primary
STARTUP;
