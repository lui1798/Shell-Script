#!/bin/bash
#By Scong

###### 内存不足时，自动释放 ######

# 获取当前主机的内存
mem_free=`free -g | awk '/Mem/{print $4}'`

#判断当前主机内存是否小于某个数

if [ ${mem_free} -lt 5 ]; then
​        sync && echo 1 > /proc/sys/vm/drop_caches
​        sync && echo 2 > /proc/sys/vm/drop_caches
​        sync && echo 3 > /proc/sys/vm/drop_caches
​        sleep 3
​        echo "Notice! Memory freed!"
else
​        echo "Notice! There is enough memory and no need to free it!"
fi