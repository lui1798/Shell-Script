#!/bin/bash
# By Scong
# Date: 2018-11-27  v1.6

############################## Xtranback Full Backup & Incremental Backup ##############################

# 数据库
Host=127.0.0.1
User=Scong
Password=123456

# 指定MySQL的配置文件,这个操作主要是为了防止不同机器，MySQL的配置文件路径不一样
Configure_Dir=/etc/my.cnf

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

# 检测Xtrabackup是否安装
if [ -f /usr/bin/innobackupex ];then
    echo "is ok"
else
    echo "is not exist"
fi

# 判断是否有进行过全备，如果无则进行全备，如果有则进行增备
if [ ! -d "${All_Backup}" ];then

# 判断是否为周日，如果是，重新进行一次全备，如果不是，则进行增量备份
#if [ $(date +%w) -eq 0 ]; then
    echo -e "\n Full backup starts... ... Please wait a moment\n"
    sleep 2
    innobackupex --defaults-file=${Configure_Dir} --host=${Host} --user=${User} --password=${Password} ${All_Backup} --no-timestamp >/dev/null 2>&1
    if [ $? = 0 ];then
      echo -e "\nComplete Successfully!"
    else
      echo -e "\n[Error] Complete Failed!"
    fi
else
    echo -e "\nIncremental backup started... ...Please wait a moment\n"
    sleep 2
    innobackupex --defaults-file=${Configure_Dir} --host=${Host} --user=${User} --password=${Password} --incremental=${Incre_Backup} --incremental-basedir=${Base_Dir}${Last_Backup} --no-timestamp >/dev/null 2>&1
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
   innobackupex --user=${User} --password=${Password} --apply-log --redo-only  ${All_Backup} >/dev/null 2>&1 

# 2、依次进行增量恢复，注意这里的6，要根据实际情况进行修改
   Dirs=`ls ${Base_Dir} | sort | tail -6`
   Dirs_arr=(${Dirs})
   echo -e "\nLog merge in progress... ...Please wait a moment\n"
   for dirs in ${Dirs_arr[@]}
   do
      innobackupex --user=${User} --password=${Password} --apply-log --redo-only ${All_Backup} --incremental-dir=${Base_Dir}${dirs}	>/dev/null 2>&1
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
innobackupex --user=${User} --password=${Password} --copy-back ${All_Backup} >/dev/null 2>&1

# 将恢复好的全备数据进行打包留底
tar -cPf ${All_Backup}.tar.gz ${All_Backup}

# 修改mysql目录的属主属组
chown -R mysql.mysql /var/lib/mysql

# 重启mysqld服务
systemctl restart mysqld

# 检测MySQL是否重启成功
netstat -antulp | grep :3306 >/dev/null 2>&1
if [ $? = 0 ];then
    echo "Database started successfully!" 
else
	echo "Database started Failed!"
fi

# 查找一星期前的文件并将其删除
#find ./  -mindepth 1 -maxdepth 1 -type d -name '*' -ctime +7 -exec rm -rf {} \;

fi

