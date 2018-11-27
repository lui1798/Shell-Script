#!/bin/bash

#By Scong

# Date: 2018-11-27  v1.0

# 数据库
User=root
Password=123456

# 时间戳
Date=`date +'%Y%m%d'`

# 基础目录
Base_Dir=/data/backup/

# 全备路径
All_Backup=${Base_Dir}All

# 增备路径
Incre_Backup=${Base_Dir}increment

# 上一次备份文件的路径
Last_Backup=$(ls ${Base_Dir} | tail -1 | cut -d\' -f2)

# 判断是否为周日，如果是，重新进行一次全备，如果不是，则进行增量备份
if [ $(date +%w) -eq 0 ]; then

    rm -rf ${All_Backup}
    innobackupex --user ${User} --password ${Password} ${All_Backup} --no-timestamp

else

    innobackupex --user ${User} --password ${Password} --incremental ${Incre_Backup}-${Date} --incremental-basedir=${Base_Dir}${Last_Backup} --no-timestamp

fi