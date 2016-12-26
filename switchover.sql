Database Switchover

-- ON PRIMARY
CONNECT / AS SYSDBA
ALTER DATABASE COMMIT TO SWITCHOVER TO STANDBY;
-- Mount old primary database as standby database
STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

--On the original standby database issue the following commands.
-- Convert standby database to primary
CONNECT / AS SYSDBA
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
-- Shutdown standby database
SHUTDOWN IMMEDIATE;

-- Open old standby database as primary
STARTUP;
