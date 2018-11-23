#1、同步时间服务器 ：

ntpdate -u cn.pool.ntp.org

#2、将/etc/sysconfig/clock 下的ZONE改为：

ZONE="Asia/Shanghai"
#3、拷贝上海市区的文件：

cp -a /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#4、重启NTP服务器：

/etc/init.d/ntpd restart

#5、如果出现“Local time zone must be set--see zic manual page 2018”的报错。那么我们需要在全局文件下添加以下内容

“echo “export TZ='Asia/Shanghai'” >> ~/.bashrc”

#最后source ~/.bashrc进行即时生效。

#6、将硬件时间与系统时间同步：

hwclock --hctosys

#7、查看硬件时间：

hwclock --show

#8、查看时间：

date