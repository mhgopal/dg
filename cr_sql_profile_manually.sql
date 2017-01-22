explain plan for select * from mytest where id=1;

explain plan for select /*+full(mytest)*/ * from mytest where id=1;

select * from table(dbms_xplan.display(null,null,'ADVANCED'));

  /*+
      BEGIN_OUTLINE_DATA
      FULL(@"SEL$1" "MYTEST"@"SEL$1")
      OUTLINE_LEAF(@"SEL$1")
      ALL_ROWS

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------
      DB_VERSION('11.2.0.3')
      OPTIMIZER_FEATURES_ENABLE('11.2.0.3')
      IGNORE_OPTIM_EMBEDDED_HINTS
      END_OUTLINE_DATA
  */

DECLARE
     l_sql               clob;
     BEGIN
     l_sql := q'!select * from mytest where id=1!';
     dbms_sqltune.import_sql_profile( sql_text => l_sql,
                                     name => 'SQLPROFILE_01',
                                     profile => sqlprof_attr(q'!FULL(@"SEL$1" "MYTEST"@"SEL$1")!',
             q'!OUTLINE_LEAF(@"SEL$1")!',
             q'!ALL_ROWS!',
             q'!DB_VERSION('11.2.0.3')!',
             q'!OPTIMIZER_FEATURES_ENABLE('11.2.0.3')!',
             q'!IGNORE_OPTIM_EMBEDDED_HINTS!'),
             force_match => true );
end;
/
