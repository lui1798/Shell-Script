#1��ͬ��ʱ������� ��

ntpdate -u cn.pool.ntp.org

#2����/etc/sysconfig/clock �µ�ZONE��Ϊ��

ZONE="Asia/Shanghai"
#3�������Ϻ��������ļ���

cp -a /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#4������NTP��������

/etc/init.d/ntpd restart

#5��������֡�Local time zone must be set--see zic manual page 2018���ı�����ô������Ҫ��ȫ���ļ��������������

��echo ��export TZ='Asia/Shanghai'�� >> ~/.bashrc��

#���source ~/.bashrc���м�ʱ��Ч��

#6����Ӳ��ʱ����ϵͳʱ��ͬ����

hwclock --hctosys

#7���鿴Ӳ��ʱ�䣺

hwclock --show

#8���鿴ʱ�䣺

date