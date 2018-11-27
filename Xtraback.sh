#!/bin/bash

#By Scong

# Date: 2018-11-27  v1.0

# ���ݿ�
User=root
Password=123456

# ʱ���
Date=`date +'%Y%m%d'`

# ����Ŀ¼
Base_Dir=/data/backup/

# ȫ��·��
All_Backup=${Base_Dir}All

# ����·��
Incre_Backup=${Base_Dir}increment

# ��һ�α����ļ���·��
Last_Backup=$(ls ${Base_Dir} | tail -1 | cut -d\' -f2)

# �ж��Ƿ�Ϊ���գ�����ǣ����½���һ��ȫ����������ǣ��������������
if [ $(date +%w) -eq 0 ]; then

    rm -rf ${All_Backup}
    innobackupex --user ${User} --password ${Password} ${All_Backup} --no-timestamp

else

    innobackupex --user ${User} --password ${Password} --incremental ${Incre_Backup}-${Date} --incremental-basedir=${Base_Dir}${Last_Backup} --no-timestamp

fi