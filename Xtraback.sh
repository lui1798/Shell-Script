#!/bin/bash
# By Scong
# Date: 2018-11-27  v1.3

############################## Xtranback Full Backup & Incremental Backup ##############################

# ���ݿ�
User=root
Password=123456

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

# �ж��Ƿ�Ϊ���գ�����ǣ����½���һ��ȫ����������ǣ��������������
if [ $(date +%w) -eq 0 ]; then
# �ж��Ƿ��н��й�ȫ��������������ȫ������������������
#if [ ! -d "${All_Backup}"];then
    rm -rf ${All_Backup}
    innobackupex --user ${User} --password ${Password} ${All_Backup} --no-timestamp
    if [ $? = 0 ];then
      echo -e "\nComplete Successfully!"
    else
      echo -e "\nComplete Failed!"
    fi
else
    innobackupex --user ${User} --password ${Password} --incremental ${Incre_Backup} --incremental-basedir=${Base_Dir}${Last_Backup} --no-timestamp
    if [ $? = 0 ];then
      echo -e "\nIncremental Successfully!!"
    else
      echo -e "\nIncremental Failed!"
    fi
fi


############################## Data Recovery ##############################


if [ $(date +%w) -eq 0 ]; then
  systemctl stop mysqld
  rm -rf /var/lib/mysql/*
  innobackupex --user ${User} --password ${Password} --apply-log --redo-only  ${All_Backup}

# 2�����ν��������ָ�
  Dirs=`ls ${Base_Dir} | sort | tail -6`
  Dirs_arr=(${Dirs})
  for dirs in ${Dirs_arr[@]}
  do
      innobackupex --user ${User} --password ${Password} --apply-log --redo-only ${All_Backup} --incremental-basedir="${dirs}"
      if [ $? -eq 0 ];then
         echo "${dirs},�ָ��ɹ���"
      else
         echo "${dirs},�ָ�ʧ�ܣ�"
      fi
  done

#���ָ��õ�ȫ�����ݵ���ʹ�ã��Ǳ��������
innobackupex --user ${User} --password ${Password} --copy-back ${All_Backup}

# ���ָ��õ�ȫ�����ݽ��д������
tar -cPf ${All_Backup}.tar.gz ${All_Backup}

# �޸�mysqlĿ¼����������
chown -R mysql.mysql /var/lib/mysql

# ����mysqld����
systemctl restart mysqld

# ����һ����ǰ���ļ�������ɾ��
find ./  -mindepth 1 -maxdepth 1 -type d -name '*' -ctime +7 -exec rm -rf {} \;

fi