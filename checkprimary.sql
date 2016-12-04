select to_char(sysdate,'dd-mon-yyyy hh24:mi:ss') Date from dual;
SELECT distinct SEQUENCE# "Last Sequence Generated", THREAD# "Thread"
FROM V$ARCHIVED_LOG
WHERE (THREAD#,FIRST_TIME ) IN (SELECT THREAD#,MAX(FIRST_TIME) FROM V$ARCHIVED_LOG GROUP BY THREAD#)
ORDER BY 1;

