STEP 1 : WE ASSUME THIS IS YOUR PROBLEM QUERY  ( NOTE THIS IS JUST AN EXAMPLE )
 

SQL> connect tuning/TUNING
Connected.

SQL> explain plan for select su_pk,su_name,su_comment,inner_view.maxamount from
t_supplier_su,
( select max(or_totalamount) maxamount,su_fk from t_order_or group by su_fk ) inner_view
where t_supplier_su.su_pk = inner_view.su_fk(+) and t_supplier_su.su_name is not null;

Explained.

SQL> select * from table(dbms_xplan.display(null,null,'ADVANCED'));

PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------------
Plan hash value: 83112093

---------------------------------------------------------------------------------------
| Id  | Operation             | Name          | Rows  | Bytes |  Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |               |   100 | 22900 |  6951    (1)| 00:01:24 |
|*  1 |  HASH JOIN RIGHT OUTER|               |   100 | 22900 |  6951    (1)| 00:01:24 |
|   2 |   VIEW                |               |    99 |  2574 |  6947    (1)| 00:01:24 |
|   3 |    HASH GROUP BY      |               |    99 |   891 |  6947    (1)| 00:01:24 |
|   4 |     TABLE ACCESS FULL | T_ORDER_OR    |  1000K|  8789K|  6902    (1)| 00:01:23 |
|*  5 |   TABLE ACCESS FULL   | T_SUPPLIER_SU |   100 | 20300 |     3    (0)| 00:00:01 |
---------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------  

1 - SEL$1
2 - SEL$2 / INNER_VIEW@SEL$1
3 - SEL$2
4 - SEL$2 / T_ORDER_OR@SEL$2
5 - SEL$1 / T_SUPPLIER_SU@SEL$1

Outline Data
------------- 

  /*+
      BEGIN_OUTLINE_DATA
      USE_HASH_AGGREGATION(@"SEL$2")
      FULL(@"SEL$2" "T_ORDER_OR"@"SEL$2")
      SWAP_JOIN_INPUTS(@"SEL$1" "INNER_VIEW"@"SEL$1")
      USE_HASH(@"SEL$1" "INNER_VIEW"@"SEL$1")
      LEADING(@"SEL$1" "T_SUPPLIER_SU"@"SEL$1" "INNER_VIEW"@"SEL$1")
      NO_ACCESS(@"SEL$1" "INNER_VIEW"@"SEL$1")
      FULL(@"SEL$1" "T_SUPPLIER_SU"@"SEL$1")
      OUTLINE_LEAF(@"SEL$1")
      OUTLINE_LEAF(@"SEL$2")
      ALL_ROWS
      DB_VERSION('11.2.0.3')
      OPTIMIZER_FEATURES_ENABLE('11.2.0.3')
      IGNORE_OPTIM_EMBEDDED_HINTS
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------  

1 - access("T_SUPPLIER_SU"."SU_PK"="INNER_VIEW"."SU_FK"(+))
5 - filter("T_SUPPLIER_SU"."SU_NAME" IS NOT NULL)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

...

60 rows selected.

 

STEP 2 : YOUR PROBLEM QUERY RUNS BETTER WITH A HINT  ( NOTE THIS IS JUST AN EXAMPLE )

SQL>  explain plan for select /*+ PUSH_PRED("INNER_VIEW"@"SEL$1") */ su_pk,su_name,su_comment,inner_view.maxamount from
t_supplier_su,
( select max(or_totalamount) maxamount,su_fk from t_order_or group by su_fk ) inner_view
where t_supplier_su.su_pk = inner_view.su_fk(+) and t_supplier_su.su_name is not null;

Explained.

 

We retrieve the outline data using dbms_xplan with the advanced attribute

 

SQL> select * from table(dbms_xplan.display(null,null,'ADVANCED'));

PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------
Plan hash value: 3140464201

-----------------------------------------------------------------------------------------
| Id  | Operation                | Name          | Rows  | Bytes | Cost (%CPU)| Time    |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |               |   100 | 21800 |   690K  (1)| 02:18:01 |
|   1 |  NESTED LOOPS OUTER      |               |   100 | 21800 |   690K  (1)| 02:18:01 |
|*  2 |   TABLE ACCESS FULL      | T_SUPPLIER_SU |   100 | 20300 |     3   (0)| 00:00:01 |
|   3 |   VIEW PUSHED PREDICATE  |               |     1 |    15 |  6900   (1)| 00:01:23 |
|   4 |    SORT GROUP BY         |               |     1 |     9 |  6900   (1)| 00:01:23 |
|*  5 |     TABLE ACCESS FULL    | T_ORDER_OR    | 10101 | 90909 |  6900   (1)| 00:01:23 |
-----------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------  

1 - SEL$1
2 - SEL$1        / T_SUPPLIER_SU@SEL$1
3 - SEL$639F1A6F / INNER_VIEW@SEL$1
4 - SEL$639F1A6F
5 - SEL$639F1A6F / T_ORDER_OR@SEL$2

Outline Data
------------- 

  /*+
      BEGIN_OUTLINE_DATA
      USE_HASH_AGGREGATION(@"SEL$639F1A6F")
      FULL(@"SEL$639F1A6F" "T_ORDER_OR"@"SEL$2")
      USE_NL(@"SEL$1" "INNER_VIEW"@"SEL$1")
      LEADING(@"SEL$1" "T_SUPPLIER_SU"@"SEL$1" "INNER_VIEW"@"SEL$1")
      NO_ACCESS(@"SEL$1" "INNER_VIEW"@"SEL$1")
      FULL(@"SEL$1" "T_SUPPLIER_SU"@"SEL$1")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$2")
      OUTLINE_LEAF(@"SEL$1")
      PUSH_PRED(@"SEL$1" "INNER_VIEW"@"SEL$1" 1)
      OUTLINE_LEAF(@"SEL$639F1A6F")
      ALL_ROWS
      DB_VERSION('11.2.0.3')
      OPTIMIZER_FEATURES_ENABLE('11.2.0.3')
      IGNORE_OPTIM_EMBEDDED_HINTS
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------  

2 - filter("T_SUPPLIER_SU"."SU_NAME" IS NOT NULL)
5 - filter("SU_FK"="T_SUPPLIER_SU"."SU_PK")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

...

 

STEP 3 : WE CREATE MANUALLY A SQL PROFILE
 


The optimizer hints / context we retrieved here above are used together with the attribute sqlprof_attr.

 

 

 

SQL> DECLARE
     l_sql               clob;
     BEGIN
     l_sql := q'!select su_pk,su_name,su_comment,inner_view.maxamount from
                 t_supplier_su,
                 ( select max(or_totalamount) maxamount,su_fk from t_order_or group by su_fk ) inner_view
                 where t_supplier_su.su_pk = inner_view.su_fk(+) and t_supplier_su.su_name is not null!';

 

     dbms_sqltune.import_sql_profile( sql_text => l_sql, 
                                     name => 'SQLPROFILE_01',
                                     profile => sqlprof_attr(q'!USE_HASH_AGGREGATION(@"SEL$639F1A6F")!',
             q'!FULL(@"SEL$639F1A6F" "T_ORDER_OR"@"SEL$2")!',
             q'!USE_NL(@"SEL$1" "INNER_VIEW"@"SEL$1")!',
             q'!LEADING(@"SEL$1" "T_SUPPLIER_SU"@"SEL$1" "INNER_VIEW"@"SEL$1")!',
             q'!NO_ACCESS(@"SEL$1" "INNER_VIEW"@"SEL$1")!',
             q'!FULL(@"SEL$1" "T_SUPPLIER_SU"@"SEL$1")!',
             q'!OUTLINE(@"SEL$1")!',
             q'!OUTLINE(@"SEL$2")!',
             q'!OUTLINE_LEAF(@"SEL$1")!',
             q'!PUSH_PRED(@"SEL$1" "INNER_VIEW"@"SEL$1" 1)!',
             q'!OUTLINE_LEAF(@"SEL$639F1A6F")!',
             q'!ALL_ROWS!',
             q'!DB_VERSION('11.2.0.3')!',
             q'!OPTIMIZER_FEATURES_ENABLE('11.2.0.3')!',
             q'!IGNORE_OPTIM_EMBEDDED_HINTS!'),
             force_match => true );
     end;
     /
 
PL/SQL procedure successfully completed.

 

STEP 4 : THE STATEMENT IS EXECUTED AS IF IT IS HINTED ( SQL PROFILE IS USED )

As soon as the sql signature matches the sql signature for which we have a sql profile the execution associated with the sql profile is used.
We get does want we want.


SQL> connect tuning/TUNING
Connected.

SQL> select * from table(dbms_xplan.display_cursor(null,null,'ADVANCED'));

PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------
SQL_ID    bma0zw5dnknxm, child number 0
-------------------------------------
select su_pk,su_name,su_comment,inner_view.maxamount from
t_supplier_su, ( select max(or_totalamount) maxamount,su_fk from
t_order_or group by su_fk ) inner_view where t_supplier_su.su_pk =
inner_view.su_fk(+) and t_supplier_su.su_name is not null

Plan hash value: 3140464201

-----------------------------------------------------------------------------------------
| Id  | Operation                |   Name        | Rows  | Bytes | Cost (%CPU)| Time    |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |               |       |       |   690K(100)|        |
|   1 |  NESTED LOOPS OUTER      |               |   100 | 21800 |   690K  (1)| 02:18:01 |
|*  2 |   TABLE ACCESS FULL      | T_SUPPLIER_SU |   100 | 20300 |     3   (0)| 00:00:01 |
|   3 |   VIEW PUSHED PREDICATE  |               |     1 |    15 |  6900   (1)| 00:01:23 |
|   4 |    SORT GROUP BY         |               |     1 |     9 |  6900   (1)| 00:01:23 |
|*  5 |     TABLE ACCESS FULL    | T_ORDER_OR    | 10101 | 90909 |  6900   (1)| 00:01:23 |
-----------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------  

   1 - SEL$1
   2 - SEL$1        / T_SUPPLIER_SU@SEL$1
   3 - SEL$639F1A6F / INNER_VIEW@SEL$1
   4 - SEL$639F1A6F
   5 - SEL$639F1A6F / T_ORDER_OR@SEL$2

Outline Data
------------- 

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('11.2.0.3')
      DB_VERSION('11.2.0.3')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$639F1A6F")
      PUSH_PRED(@"SEL$1" "INNER_VIEW"@"SEL$1" 1)
      OUTLINE_LEAF(@"SEL$1")
      OUTLINE(@"SEL$2")
      OUTLINE(@"SEL$1")
      FULL(@"SEL$1" "T_SUPPLIER_SU"@"SEL$1")
      NO_ACCESS(@"SEL$1" "INNER_VIEW"@"SEL$1")
      LEADING(@"SEL$1" "T_SUPPLIER_SU"@"SEL$1" "INNER_VIEW"@"SEL$1")
      USE_NL(@"SEL$1" "INNER_VIEW"@"SEL$1")
      FULL(@"SEL$639F1A6F" "T_ORDER_OR"@"SEL$2")
      USE_HASH_AGGREGATION(@"SEL$639F1A6F")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------  

   2 - filter("T_SUPPLIER_SU"."SU_NAME" IS NOT NULL)
   5 - filter("SU_FK"="T_SUPPLIER_SU"."SU_PK")

Column Projection Information (identified by operation id):
-----------------------------------------------------------  

   1 - "T_SUPPLIER_SU"."SU_PK"[NUMBER,22],
       "T_SUPPLIER_SU"."SU_NAME"[VARCHAR2,400], "SU_COMMENT"[VARCHAR2,400],
       "INNER_VIEW"."MAXAMOUNT"[NUMBER,22]
   2 - "T_SUPPLIER_SU"."SU_PK"[NUMBER,22],
       "T_SUPPLIER_SU"."SU_NAME"[VARCHAR2,400], "SU_COMMENT"[VARCHAR2,400]
   3 - "INNER_VIEW"."MAXAMOUNT"[NUMBER,22]
   4 - (#keys=1) "SU_FK"[NUMBER,22], MAX("OR_TOTALAMOUNT")[22]
   5 - "SU_FK"[NUMBER,22], "OR_TOTALAMOUNT"[NUMBER,22]Note
-----
   - SQL profile SQLPROFILE_01 used for this statement

 

 

SQL> connect / as sysdba
Connected.

 SQL>  begin dbms_sqltune.alter_sql_profile('SQLPROFILE_01','STATUS','DISABLED'); end;
  2  /

PL/SQL procedure successfully completed.

 

SQL>  begin dbms_sqltune.drop_sql_profile('SQLPROFILE_01'); end;
  2  /
