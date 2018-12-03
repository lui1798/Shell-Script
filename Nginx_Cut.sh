#!/bin/bash
# By Scong

# Nginx日志目录
Logs_Path=/var/logs/nginx

# 切割文件日期
Log_Date=$(date -d "yesterday" +%Y%m%d)

# 进入到Nginx日志文件目录下
cd ${Logs_Path}

# 循环切割日志,并进行压缩
arr=(access.log error.log)
for file in ${arr[@]}
do
​        /bin/mv ${Logs_Path}${file} ${Logs_Path}${file}-${Log_Date}
​        /bin/gzip ${Logs_Path}${file}-${Log_Date}
done

# 可以使用“gzip -d xxxx.gz”进行解压

# 向Ngnix主进程发送USR1信号. USR1信号是重新打开日志文件
sudo kill -USR1 `cat /run/nginx.pid`

# 删除30天的日志文件
find ${Logs_Path}  -type f -name '*.gz' -ctime +7 -exec rm -rf {} \;

# 配合Cron定时任务进行每天都日志分割

