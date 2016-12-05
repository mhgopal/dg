alter session set nls_date_format='DD-MON-RRRR HH24:MI:SS';

select name, thread#, sequence#, status, first_time, next_time, first_change#, next_change# from v$archived_log
where <scn_number> between first_change# and next_change#;

SEQUENCE# number usually shows up on the archivelog name. 

If you see 'D' in the STATUS column, 
the archive log has been deleted from the disk. You may need to restore it from the tape.
rman target /
list backup of archivelog from logseq=<from_number> until logseq=<until_number>; 
restore archivelog from logseq=<from_number> until logseq=<until_number>;
