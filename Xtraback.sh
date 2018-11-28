#!/bin/bash
# By Scong
# Date: 2018-11-27  v1.4

############################## Xtranback Full Backup & Incremental Backup ##############################

# 数据库
User=Scong
Password=123456

# 时间戳
Date=`date +'%Y%m%d'`

# 基础目录
Base_Dir=/data/backup/

# 全备路径
All_Backup=${Base_Dir}all

# 增备路径
Incre_Backup=${Base_Dir}increment-${Date}

# 上一次备份文件的路径
Last_Backup=$(ls ${Base_Dir} | tail -1 | cut -d\' -f2)

# 判断是否有进行过全备，如果无则进行全备，如果有则进行增备
if [ ! -d "${All_Backup}" ];then
# 判断是否为周日，如果是，重新进行一次全备，如果不是，则进行增量备份
#if [ $(date +%w) -eq 0 ]; then
    echo -e "\n Full backup starts... ... Please wait a moment\n"
    sleep 2
    innobackupex --user ${User} --password ${Password} ${All_Backup} --no-timestamp
    if [ $? = 0 ];then
      echo -e "\nComplete Successfully!"
    else
      echo -e "\n[Error] Complete Failed!"
    fi
else
    echo -e "\nIncremental backup started... ...Please wait a moment\n"
    sleep 2
    innobackupex --user ${User} --password ${Password} --incremental ${Incre_Backup} --incremental-basedir=${Base_Dir}${Last_Backup} --no-timestamp
    if [ $? = 0 ];then
      echo -e "\nIncremental Successfully!!!"
    else
      echo -e "\n[Error] Incremental Failed!!!"
    fi
fi

############################## Data Recovery ##############################

# 每周日进行一次日志合并
if [ $(date +%w) -eq 0 ]; then
   systemctl stop mysqld
   rm -rf /var/lib/mysql/*
   echo -e  "\nPrepare for your first data recovery......Please wait a moment\n"
   sleep 2
   innobackupex --user ${User} --password ${Password} --apply-log --redo-only  ${All_Backup}

# 2、依次进行增量恢复，注意这里的6，要根据实际情况进行修改
   Dirs=`ls ${Base_Dir} | sort | tail -6`
   Dirs_arr=(${Dirs})
   echo -e "\nLog merge in progress... ...Please wait a moment\n"
   for dirs in ${Dirs_arr[@]}
   do
      innobackupex --user ${User} --password ${Password} --apply-log --redo-only ${All_Backup} --incremental-dir=${Base_Dir}${dirs}
      if [ $? -eq 0 ];then
         echo "${dirs},Restore Successfully！"
		 sleep 2
      else
         echo "[Error] ${dirs},Restore Failed！"
         exit
      fi
   done

#将恢复好的全备数据导入使用（非必须操作）
echo -e "\nDatabase copy in progress......Do not operate..."
sleep 2
innobackupex --user ${User} --password ${Password} --copy-back ${All_Backup}

# 将恢复好的全备数据进行打包留底
tar -cPf ${All_Backup}.tar.gz ${All_Backup}

# 修改mysql目录的属主属组
chown -R mysql.mysql /var/lib/mysql

# 重启mysqld服务
systemctl restart mysqld

# 查找一星期前的文件并将其删除
#find ./  -mindepth 1 -maxdepth 1 -type d -name '*' -ctime +7 -exec rm -rf {} \;

fi

