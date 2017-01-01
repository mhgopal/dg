select cast(
            from_tz(
                    cast( oldest_flashback_time as timestamp )
                   ,dbtimezone )
            at time zone 'US/Eastern' as date ) oldest_db_fb
       ,round((sysdate - oldest_flashback_time) * 24, 1) oldest_db_fb_hours
  from v$flashback_database_log;
