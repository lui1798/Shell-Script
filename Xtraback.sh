#!/bin/bash

#By Scong

#2018-11-27 v1.0

#Êý¾Ý¿â
User=root
Password=123456

Date=`date +'%Y%m%d'`
Base_Dir=/data/backup/
All_Backup=/data/backup/All
Incre_Backup=/data/backup/increment
Last_Backup=$(ls ?${Base_Dir} | tail -1 | cut -d\' -f2)

if [ $(date +%w) -eq 0 ]; then
?    rm -rf ${All_Backup}
?    innobackupex --user ${User} --password ${Password} ${All_Backup} --no-timestamp

else
?    innobackupex --user ${User} --password ${Password} --incremental ${Incre_Backup}-${Date} --incremental-basedir=${Base_Dir}${Last_Backup} --no-timestamp
fi