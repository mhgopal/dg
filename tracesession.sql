display sid of current session
select 
   sys_context('USERENV','SID') 
from dual;


SELECT p.tracefile
FROM   v$session s
       JOIN v$process p ON s.paddr = p.addr
WHERE  s.sid = 265;

exec dbms_system.set_sql_trace_in_session(265,22520,true);
exec dbms_system.set_sql_trace_in_session(81,29902,true);
--
Trace session by module

BEGIN 
  DBMS_MONITOR.SERV_MOD_ACT_TRACE_ENABLE(
    service_name  => 'ACCTG'   ,
    module_name   => 'PAYROLL' ,
    waits         =>  true     ,
    binds         =>  false    ,
    instance_name => 'inst1'   );
END;
