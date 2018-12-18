#!/bin/bash
# By Scong
# Date 2018-12-18

# 主机列表以及同步的目录根据实际情况进行修改
Hosts="192.168.1.1,192.168.1.2,192.168.1.3,...,192.168.1.254"
LocalConfPath="/data/"
RemoteConfPath="/data/"

# 远程主机信息
Account="root"
Port="22"

# 内部域的分隔符
IFS=","

# 主机列数组
hosts_arr=($Hosts)

for host in ${hosts_arr[@]}
do
	#同步文件
	rsync -avuzpg --exclude=sync_conf.sh "-e ssh -p $Port"  $LocalConfPath $Account@$host:$RemoteConfPath
	
	# 为防止权限的问题，同步完成后进行权限授权
    ssh -p $Port $Account@$host chmod -R 755 $RemoteConfPath
	if [ $? = 0 ];then
		echo "$host 同步成功!"
	else
		echo "$host 同步失败!"
	fi
done


