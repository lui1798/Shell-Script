#!/bin/bash

#By Scong

############# 配合Keepalived进行使用 #############

#检验数据库是否存活

Host=127.0.0.1
User=root 
Passwd=123456

mysql -h${Host} -u​$${User}  -p​$${Passwd}​$ -e "show status;" > /dev/null 2>&1 
if [ $? == 0 ] 
then 
​       echo " ​$host mysql login successfully " 
​     exit 0 
​     else 
​       service keepalived stop 
​     exit 2 
fi