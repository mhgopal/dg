#!/bin/bash

# ------------------------------------------------------------------------------
# FUNCTION
#   Displays ASM diskgroup information, space usage. Displays usage by DISKS.
#   Displays ongoing operations and list of files on diskgroup.
# NOTES
#   Developed for 11g Oracle Version. The entry must be in the /etc/oratab
#   for ASM instance
# CREATED
#   Aychin Gasimov 03/2011 aychin.gasimov@gmail.com
#
# MODIFIED
#   Xavier Picamal 08/2012
#       Added -r key
#   Xavier Picamal 09/2012 
#       NEW flag -p for Diskgroup Partners query.
#       NEW flag -fg for FailGroups, Diskgroups and Headers
#   Aychin Gasimov 08/2014
#       Removed reading ASM instance name and GI home info from oratab.
#       Now script automatically identifies all required variables.
#       Prints information about ASM and GI on execution
# ------------------------------------------------------------------------------

# set_crshome Author AG
#             Function for setting global variable CRS_HOME in the script, not in the environment.
#             It also set CRS_INSTALL_TYPE variable to RESTART or CLUSTER depending on installation type.
declare -r set_crshome_NO_OLRLOC=102
declare -r set_crshome_NO_HOMEINV=103
function set_crshome {
  local -i retCode=0
  # Get CRS_HOME from olr.loc
  local olrFile
  local PLATFORM=$(/bin/uname)
  case $PLATFORM in
      Linux) olrFile="/etc/oracle/olr.loc" ;;
      HP-UX) olrFile="/var/opt/oracle/olr.loc" ;;
      SunOS) olrFile="/var/opt/oracle/olr.loc" ;;
        AIX) olrFile="/etc/oracle/olr.loc" ;;
  esac
  if [[ -f $olrFile ]]; then
      CRS_HOME="$(grep -i crs_home $olrFile)" && CRS_HOME=${CRS_HOME#*=}
      [[ -z $CRS_HOME ]] && return $set_crshome_NO_OLRLOC
  else
      return $set_crshome_NO_OLRLOC
  fi
  # Now identify is it Cluster Installation or Oracle Restart
  local -i is_cluster
  if [[ -f $CRS_HOME/inventory/ContentsXML/oraclehomeproperties.xml ]]; then
      is_cluster=$(grep -i "" $CRS_HOME/inventory/ContentsXML/oraclehomeproperties.xml | wc -l)
      [[ $is_cluster -eq 0 ]] && CRS_INSTALL_TYPE="RESTART" || CRS_INSTALL_TYPE="CLUSTER"
  else
      return $set_crshome_NO_HOMEINV
  fi
  return 0 
}

# Setting environment for ASM instance
set_crshome
set_crshome_RES=$?
    
mess_no_olr="No olr.loc file on the system or corrupt entry! Grid Infrastructure not installed or have configuration problems!"
mess_no_homeinv="No oraclehomeproperties.xml in $CRS_HOME/inventory/ContentsXML folder, can not identify Cluster software installation type!"
[[ $set_crshome_RES -eq $set_crshome_NO_OLRLOC ]] && echo -e $mess_no_olr && exit $set_crshome_NO_OLRLOC 
[[ $set_crshome_RES -eq $set_crshome_NO_HOMEINV ]] && echo -e $mess_no_homeinv && exit $set_crshome_NO_HOMEINV 

t_sid=$( ps -eo args | grep -v grep | grep asm_pmon )
if [[ -z $t_sid ]]; then
     echo "ASM instance is not running, can not get pmon process of ASM instance!"
     exit 1
fi
t_sid=${t_sid##*_}

echo -e "\n   ASM Instance name: "$t_sid
echo "             GI home: "$CRS_HOME
echo "GI installation type: "$CRS_INSTALL_TYPE

export ORACLE_HOME=$CRS_HOME
export ORACLE_BASE="$($CRS_HOME/bin/orabase)"
export ORACLE_SID=$t_sid

# End setting environment

SQLPLUS=$ORACLE_HOME/bin/sqlplus

dispinfo () {
 echo "Use -d key to display usage by disks"
 echo "Use -o key to display asm operations in progress (disk rebalancing)"
 echo "Use -r key to display min, max and avergage free megabytes by diskgroups"
 echo "Use -f  to list files and directories of the disk group"
 echo "Use -fg to list failgroups, diskgroups and headers"
 echo "Use -p to list partner disks"
 }

case "$1" in
 -d)
     $SQLPLUS -S '/ as sysasm' << EOF
       set linesize 200
       set pagesize 50000
       col path format a50
       col free_pct format a8
       select group_number,name,path,state,os_mb,total_mb,free_mb,round(free_mb*100/total_mb)||'%' free_pct from v\$asm_disk where header_status='MEMBER';
EOF
     dispinfo;
     ;;
 -o)
     $SQLPLUS -S '/ as sysasm' << EOF
       set linesize 200
       select * from v\$asm_operation;
EOF
     dispinfo;
     ;;
 -f)
     if [ -e $2 ]; then
      echo "Please specify diskgroup name after -f key"
     else
      $SQLPLUS -S '/ as sysasm' << EOF
       alter session set nls_date_format='dd.mm.yyyy hh24:mi:ss';
       set linesize 200
       set pagesize 50000
       variable pindx number;
       exec select group_number into :pindx from v\$asm_diskgroup where upper(name)=upper('$2');
       col reference_index noprint
       break on reference_index skip 1 on report
       compute sum label "Total size of all files in MBytes on diskgroup $2" of mb on report
       col type format a15
       col files format a80
       select decode(aa.alias_directory,'Y',sys_connect_by_path(aa.name,'/'),'N',lpadaa.aa.name) files,  aa.REFERENCE_INDEX,
              b.type, b.blocks, round(b.bytes/1024/1024,0) mb, b.creation_date, b.modification_date
         from (select * from v\$asm_alias order by name) aa,
              (select parent_index from v\$asm_alias where group_number = :pindx and alias_index=0) a,
              (select * from v\$asm_file where group_number = :pindx) b
         where aa.file_number=b.file_number(+)
         start with aa.PARENT_INDEX=a.parent_index
         connect by prior aa.REFERENCE_INDEX=aa.PARENT_INDEX;
EOF
     dispinfo;
     fi;
     ;;
 -r)
     $SQLPLUS -S '/ as sysasm' << EOF
     alter session set nls_date_format='dd.mm.yyyy hh24:mi:ss';
     set linesize 200
     set pagesize 5000
     select dg.name,dg.allocation_unit_size/1024/1024 "AU(Mb)",min(d.free_mb) Min,
     max(d.free_mb) Max, round(avg(d.free_mb),2) as Avg
     from gv\$asm_disk d, gv\$asm_diskgroup dg
     where d.group_number = dg.group_number
     group by dg.name, dg.allocation_unit_size/1024/1024;
EOF
     dispinfo;
     ;;
 # XPA 2012-11-21 -fg flag BEGINS here
 -fg) 
     $SQLPLUS -S '/ as sysasm' << EOF
     set linesize 200
     set pagesize 300
     col path format a50
     select mount_status,header_status,state,redundancy,failgroup,path from v\$asm_disk order by failgroup;
EOF
     dispinfo;
     ;;
 # XPA 2012-11-21 -fg flag ENDS here
 # XPA 2012-09 -p flag begins here
 -p)
    $SQLPLUS -S '/ as sysasm' << EOF     
    alter session set nls_date_format='dd.mm.yyyy hh24:mi:ss';     
    set linesize 200     
    set pagesize 50000     
    col "Partner Disks" format a80     
    select d||' => '||listagg(p, ',') within group (order by p) "Partner Disks"
      from (
       select ad1.failgroup||'('||to_char(ad1.disk_number, 'fm00')||')' d,
              ad2.failgroup||'('||listagg(to_char(p.number_kfdpartner, 'fm00'), ',') within group (order by ad1.disk_number)||')' p
       from gv\$asm_disk ad1, x\$kfdpartner p, v\$asm_disk ad2
       where ad1.disk_number = p.disk
         and p.number_kfdpartner=ad2.disk_number
         and ad1.group_number = p.grp
         and ad2.group_number = p.grp
       group by ad1.failgroup, ad1.disk_number, ad2.failgroup
           )
    group by d
    order by d;
EOF
     dispinfo;
     ;;
 -h)
     dispinfo;
     ;;
  *)
     $SQLPLUS -S '/ as sysasm' << EOF
      set linesize 200
      set pagesize 50000
      col free_pct format a8
      select group_number,name,sector_size,block_size,allocation_unit_size,state,total_mb,free_mb,round(free_mb*100/total_mb)||'%' free_pct from v\$asm_diskgroup;
EOF
     dispinfo;
esac

exit 0

