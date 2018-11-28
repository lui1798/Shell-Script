#!/bin/bash
# By Scong
# Date: 2018-11-27  v1.5

############################## Xtranback Full Backup & Incremental Backup ##############################

# ���ݿ�
User=Scong
Password=123456

# ָ��MySQL�������ļ�,���������Ҫ��Ϊ�˷�ֹ��ͬ������MySQL�������ļ�·����һ��
Configure_Dir=/etc/my.cnf

# ʱ���
Date=`date +'%Y%m%d'`

# ����Ŀ¼
Base_Dir=/data/backup/

# ȫ��·��
All_Backup=${Base_Dir}all

# ����·��
Incre_Backup=${Base_Dir}increment-${Date}

# ��һ�α����ļ���·��
Last_Backup=$(ls ${Base_Dir} | tail -1 | cut -d\' -f2)

# ���Xtrabackup�Ƿ�װ
if [ -f /usr/bin/innobackupex ];then
    echo "is ok"
else
    echo "is not exist"
fi

# �ж��Ƿ��н��й�ȫ��������������ȫ������������������
if [ ! -d "${All_Backup}" ];then

# �ж��Ƿ�Ϊ���գ�����ǣ����½���һ��ȫ����������ǣ��������������
#if [ $(date +%w) -eq 0 ]; then
    echo -e "\n Full backup starts... ... Please wait a moment\n"
    sleep 2
    innobackupex --defaults-file=${Configure_Dir} --user ${User} --password ${Password} ${All_Backup} --no-timestamp >/dev/null 2>&1
    if [ $? = 0 ];then
      echo -e "\nComplete Successfully!"
    else
      echo -e "\n[Error] Complete Failed!"
    fi
else
    echo -e "\nIncremental backup started... ...Please wait a moment\n"
    sleep 2
    innobackupex --defaults-file=${Configure_Dir} --user ${User} --password ${Password} --incremental ${Incre_Backup} --incremental-basedir=${Base_Dir}${Last_Backup} --no-timestamp >/dev/null 2>&1
    if [ $? = 0 ];then
      echo -e "\nIncremental Successfully!!!"
    else
      echo -e "\n[Error] Incremental Failed!!!"
    fi
fi

############################## Data Recovery ##############################

# ÿ���ս���һ����־�ϲ�
if [ $(date +%w) -eq 0 ]; then
   systemctl stop mysqld
   rm -rf /var/lib/mysql/*
   echo -e  "\nPrepare for your first data recovery......Please wait a moment\n"
   sleep 2
   innobackupex --user ${User} --password ${Password} --apply-log --redo-only  ${All_Backup} >/dev/null 2>&1 

# 2�����ν��������ָ���ע�������6��Ҫ����ʵ����������޸�
   Dirs=`ls ${Base_Dir} | sort | tail -6`
   Dirs_arr=(${Dirs})
   echo -e "\nLog merge in progress... ...Please wait a moment\n"
   for dirs in ${Dirs_arr[@]}
   do
      innobackupex --user ${User} --password ${Password} --apply-log --redo-only ${All_Backup} --incremental-dir=${Base_Dir}${dirs}	>/dev/null 2>&1
      if [ $? -eq 0 ];then
         echo "${dirs},Restore Successfully��"
		 sleep 2
      else
         echo "[Error] ${dirs},Restore Failed��"
         exit
      fi
   done

#���ָ��õ�ȫ�����ݵ���ʹ�ã��Ǳ��������
echo -e "\nDatabase copy in progress......Do not operate..."
sleep 2
innobackupex --user ${User} --password ${Password} --copy-back ${All_Backup} >/dev/null 2>&1

# ���ָ��õ�ȫ�����ݽ��д������
tar -cPf ${All_Backup}.tar.gz ${All_Backup}

# �޸�mysqlĿ¼����������
chown -R mysql.mysql /var/lib/mysql

# ����mysqld����
systemctl restart mysqld

# ���MySQL�Ƿ������ɹ�
netstat -antulp | grep :3306 >/dev/null 2>&1
if [ $? = 0 ];then
    echo "Database started successfully!" 
else
	echo "Database started Failed!"
fi

# ����һ����ǰ���ļ�������ɾ��
#find ./  -mindepth 1 -maxdepth 1 -type d -name '*' -ctime +7 -exec rm -rf {} \;

fi

