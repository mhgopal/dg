#!/bin/bash -x

function d
{
echo "###################################################"
echo "1 - Display SQL Commands"
echo "2 - Display CRS TroubleShooting Commands"
echo "3 - Display OMS commands"
echo "4 - Display rman commands"
echo "5 - Display dg commands"
echo "6 - Display network commands"
}

choice="y"

d

while [[ "$choice" != "q" ]]; do

read choice
echo "choice is :$choice:"


case $choice in
1) echo "You chose 1"
cat dispsql.txt
;;

2) echo "You chose 2"
cat dispcrs.txt
;;
3) echo " You chose 3"
cat dispoms.txt
;;
4) echo "You chose 4"
cat disprman.txt
;;
5) echo "You chose 5"
cat dispdg.txt
;;

6) echo "You chose 6"
cat dispnetwork.txt
;;
esac
done

