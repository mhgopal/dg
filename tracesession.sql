SELECT p.tracefile
FROM   v$session s
       JOIN v$process p ON s.paddr = p.addr
WHERE  s.sid = 81;

exec dbms_system.set_sql_trace_in_session(81,29902,true);
exec dbms_system.set_sql_trace_in_session(81,29902,true);
