#!/bin/bash
# By Scong
# Date: 2018-11-27  v1.2

############################## Xtranback Full Backup & Incremental Backup ##############################

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

# 数据恢复

if [ $(date +%w) -eq 2 ]; then
  rm -rf /var/lib/mysql/*
  innobackupex --user ${User} --password ${Password} --apply-log --redo-only  ${All_Backup}

# 2、依次进行增量恢复
  Dirs=`ls /data/backup/ | sort | tail -6`
  Dirs_arr=(${Dirs})
  for dirs in ${Dirs_arr[@]}
  do
?      innobackupex --user ${User} --password ${Password} --apply-log --redo-only ${All_Backup} --incremental-basedir="${dirs}"
?      if [ $? -eq 0 ];then
?         echo "${dirs},恢复成功！"
?      else
?         echo "${dirs},恢复失败！"
?      fi
  done

将恢复好的全备数据导入使用（非必须操作）

innobackupex --user ${User} --password ${Password} --copy-back ${All_Backup}


# 将恢复好的全备数据进行打包
tar -cf ${All_Backup}.tar.gz ${All_Backup}

# 修改mysql目录的属主属组
chown -R mysql.mysql /var/lib/mysql

# 重启mysqld服务
systemctl restart mysqld

# 查找一星期前的文件并将其删除
find ./  -mindepth 1 -maxdepth 1 -type d -name '*' -ctime +7 -exec rm -rf {} \;

fi