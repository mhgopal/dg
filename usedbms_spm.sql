
/*
The core of spm relies on the fact to generate
new sql id , new plan and associating
it with the old sql handle
*/

Example:-
Run THE sql in session
alter session set container=scrncy;
alter session set current_schema=mhgopal;

var myid number
exec :myid:=1
SELECT id,val FROM order_hdr WHERE id=:myid;

--get the original sql_id, plan hash value
select * from table (dbms_xplan.display_cursor(null,null,'TYPICAL'))

--Create plan baseline
variable cnt number;
execute :cnt := dbms_spm.load_plans_from_cursor_cache(sql_id=>'&orig_sql_id');
 
--
select sql_handle,sql_text,plan_name,enabled,created
from
dba_sql_plan_baselines
where
sql_text like '%&ORIGINAL_FULL_SQL%' order by created desc;

--DISABLE the plan
exec :cnt := dbms_spm.alter_sql_plan_baseline(sql_handle =>'&SQL_HANDLE',-
						  plan_name => '&SQL_PLAN', -
						  attribute_name=>'enabled',-
						  attribute_value=>'NO');

--verify plan is disabled


select sql_handle,sql_text,plan_name,enabled
from
dba_sql_plan_baselines
where
sql_text like '%&ORIGINAL_FULL_SQL%';


--Rerun QUERY with index hint

create index mhgopal.idx_ord on order_hdr(id);

SELECT /*+INDEX( order_hdr idx_ord)*/id,val FROM order_hdr WHERE id=:myid;

select * from table (dbms_xplan.display_cursor(null,null,'TYPICAL'))
/


--Check the new execution plan
--Switch the execution plan for the original, unhinted sql
execute :cnt := dbms_spm.load_plans_from_cursor_cache(sql_id => '&new_sql_id',-
						      plan_hash_value => &new_plan_hash_value,-
						      sql_handle=>'&old_SQL_HANDLE');
/


--Check new plan for baseline

select sql_handle,sql_text,plan_name,enabled
from
dba_sql_plan_baselines
where
sql_text like '%&ORIGINAL_FULL_SQL%';

--rerun original sql
SELECT id,val FROM order_hdr WHERE id=:myid;

--check new plan
select * from table (dbms_xplan.display_cursor(null,null,'TYPICAL'));


--

