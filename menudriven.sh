#!/bin/bash
# A menu driven shell script sample template 
## ----------------------------------
# Step #1: Define variables
# ----------------------------------
EDITOR=vim
PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'
 
# ----------------------------------
# Step #2: User defined function
# ----------------------------------
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}
 
one(){
       #This is for listener
       echo "Enter Target DB Name:"
        read MYTRGDBNM
	echo "Enter Auxiliary DB Name:"
        read MYADBNAME
	echo "Enter RAC Auxiliary SID Name:"
        read RACMYDBSID
        echo "Oracle Home"
        read MYOH
        echo "Enter MYHOSTNAME"
        read MYHOSTNAME
        echo "Enter Auxiliary PORT"
        read MYPORT

       #This is for host

      #This is for Port
        
cat<<EOM
######################################
# Entries for Static Listener
#####################################
EOM

cat <<EOM
SID_LIST_LISTENER=
   (SID_LIST=
        (SID_DESC=
          (GLOBAL_DBNAME=$MYADBNAME)
          (SID_NAME=$RACMYDBSID)
          (ORACLE_HOME=$MYOH)
        )
      )
EOM

cat<<EOM

EOM

cat<<EOM
######################################
# Entries for Tnsnames
#####################################
EOM
cat<<EOM
$MYADBNAME=
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $MYHOSTNAME)(PORT = MYPORT))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = $MYADBNAME)
      (UR=A)
    )
  )
EOM

cat<<EOM
######################################
# Copy Source Password file to Auxiliary
#####################################
EOM
cat <<EOM
Copy The source passwod file on to the Auxilary's HOME Directory.
EOM
cat<<EOM
######################################
# Actual Duplicate Command
#####################################
EOM

cat <<EOM
######################################
# Connect rman
#####################################

rman target sys@$MYTRGDBNAME auxiliary sys@$MYADBNAME/
EOM

cat<<EOM
DUPLICATE TARGET DATABASE to $MYADBNAME
  SPFILE
parameter_value_convert '$MYTRGDBNM','$MYADBNAME'
SET DB_UNIQUE_NAME='$MYADBNAME'
set instance_number='1'
    SET DB_FILE_NAME_CONVERT='+DATA/$MYTRGDBNM/','+DATA/$MYADBNAME/'
    SET LOG_FILE_NAME_CONVERT='+DATA/$MYTRGDBNM/','+DATA/$MYDBNAME/'
  NOFILENAMECHECK;
EOM

        pause
}
 
# do something in two()
two(){
	echo "two() called"
        pause
}
 
# function to display menus
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Generate Rman Duplicate Code"
	echo "2. Reset Terminal"
	echo "3. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options(){
	local choice
	read -p "Enter choice [ 1 - 3] " choice
	case $choice in
		1) one ;;
		2) two ;;
		3) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}
 
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
 
	show_menus
	read_options
done
