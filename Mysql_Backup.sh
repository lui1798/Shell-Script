#!/bin/bash
# By Scong

############ 加密备份数据库，并计算备份的时长 ############

# 备份文件存放处,路径因实际情况更改
Dumpdir=/opt/

# 日期标签
Date=`date +%Y%m%d`
cd ${Dumpdir}

# 数据库备份命名,命名因实际情况更改
DumpFileName=database-${Date}.sql

# 如需要压缩，可以添加压缩
#GzDumpFileName=database-${Date}.sql.tar.gz

# 备份用户信息参数,Host看实际生产环境下而决定
# Host=127.0.0.1
UserName=root
Passwd=scirh747200..

# 记录程序执行开始的时间
StartTime=`date +'%Y-%m-%d %H:%M:%S'`

# 开始执行程序

# 备份Tips1
echo -e "\nThe database is being backed up. Waiting... ...\n"

# 数据库全备
# mysqldump -u${UserName} -p${Passwd} --all-databases  --single-transaction > ${DumpFileName}

# 备份时指定库,利用数组的方式
arr_databases=(wordpress)
mysqldump -u${UserName} -p${Passwd} --single-transaction --databases ${arr_databases[@]} > ${DumpFileName}

# 备份时指定备份某个库的某几张表
# DbName=database
# arr_tables=(table1 table2 ... tableN)
# mysqldump -u${UserName} -p${Passwd} ${DbName} ${arr_tables[@]} > ${DumpFileName}

# 压缩数据库备份文件
# tar -czvf ${Dumpdir}${GzDumpFileName} ${DumpFileName}

# 加密数据库备份文件,为安全起见，建议使用随机密码
GpgPasswd=123scong
gpg -c --batch --passphrase ${gzpasswd} ${DumpFileName}

# 如果需要解密可以执行以下命令，不建议加在本脚本，本脚本写入解密命令只为了提供参考
# gpg -d --batch --passphrase 密码 -o 解密为的文件（xxx.sql） xxx.sql.gpg

# 如果备份出来的文件不是保存在本地，而是在其他主机，可以使用rsync进行同步，需提前做好互信操作
#rsync -zvx -avzpg --exclude=rsync_conf.sh ${Dumpdir}${DumpFileName}.gpg username@IP:/RemotePath

# 然后删除指定时间点的备份文件
#find ${Dumpdir} -type f -name '*' -ctime +7 -exec rm -rf {} \;

# 如果需要自动导入，可以添加下面导入的语句,如果是远程的话，需要添加远程主机
# RemoteHost=127.0.0.1
# To_Database=Scong
# mysql -h${RemoteHost} -u${UserName} -p${Passwd} ${To_Database} < ${Dumpdir}${DumpFileName}

# 备份Tips2
echo -e "\nThe database backup is complete. In Time... ...\n"

# 记录程序执行的时间
EndTime=`date +'%Y-%m-%d %H:%M:%S'`

# 将时间戳转换成分钟
Start_mins=$(date --date="$StartTime" +%s)/60
End_mins=$(date --date="$EndTime +%s")/60

# 最终计算出程序执行的总时长
echo "本次运行总时长为："$((End_mins-Start_mins))"Mins"