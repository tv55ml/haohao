#!/bin/bash
#centos7���á�
#���ڻ�Դ�رշ���ǽselinux
#��������Ƿ�ͨ��
_check () {
test -f /usr/lib/systemd/system/smb.service && {
if (whiptail --title "�Ƿ�ж���Ѱ�װ��sMb����" --yes-button "YES" --no-button "NO" --yesno "�����Ѱ�װsmb,�Ƿ�ж����װ?" 10 60) then
 echo "You chose Man Exit status was $?."
 systemctl stop smb
 yum remove samba -y && rm -rfv /etc/samba/
else
 exit 0
fi
}
ping -w 3 qq.com || {
echo "�����쳣,�ű���ֹ"
exit 1
}
}
#��������
_info () {
user=$(whiptail --title "samba��������" --inputbox "����smb�����˻���?" 10 60 smb 3>&1 1>&2 2>&3)
pass=$(whiptail --title "samba�˻�����" --passwordbox "Enter your password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)
smb_PATH=$(whiptail --title "samba�������·��" --inputbox "���ù���·������ \"/data\"" 10 60 \/data 3>&1 1>&2 2>&3)
[ ! $user ] && {
 echo "�������,��װ�ж�"
 exit 2
} 
[ ! $pass ] && {
 echo "�������,��װ�ж�"
 exit 2
} 
[ ! $PATH ] && {
 echo "�������,��װ�ж�"
 exit 2
} 
}
_centos7_int () {
#�滻������yumԴ
rm -fv rm -f /etc/yum.repos.d/*
while [ true ]; do curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && break 1 ;done
while [ true ]; do curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && break 1 ;done
while [ true ]; do curl -o /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo && break 1 ;done
sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
yum makecache fast
#�رշ���ǽselinux
sed -i 's#=enforcing#=disabled#g' /etc/selinux/config
setenforce 0
getenforce
systemctl stop firewalld.service
systemctl disable firewalld.service
sed -i 's@.*UseDNS yes@UseDNS no@' /etc/ssh/sshd_config
#ʱ��ͬ��
sed '/ntpdate/d' /var/spool/cron/root -i
echo '*/5 * * * * /usr/sbin/ntpdate ntp4.aliyun.com>/dev/null 2>&1' >>/var/spool/cron/root
crontab -l
}
#smb��װ
_smb_install () {
yum install samba expect -y
mkdir -pv /etc/samba/
\cp -av /etc/samba/smb.conf /etc/samba/smb.conf.bak
cat /etc/samba/smb.conf.bak | grep -v "#" | grep -v ";" | grep -v "^$" > /etc/samba/smb.conf
cat > /etc/samba/smb.conf [global]
tworkgroup = SAMBA
tsecurity = user
tpassdb backend = tdbsam
tprinting = cups
tprintcap name = cups
tload printers = yes
tcups options = raw
[homes]
tcomment = Home Directories
tvalid users = %S, %D%w%S
tbrowseable = No
tread only = No
tinherit acls = Yes
[printers]
tcomment = All Printers
tpath = /var/tmp
tprintable = Yes
tcreate mask = 0600
tbrowseable = No
[print\$]
tcomment = Printer Drivers
tpath = /var/lib/samba/drivers
twrite list = @printadmin root
tforce group = @printadmin
tcreate mask = 0664
tdirectory mask = 0775
[database]
comment = Do not arbitrarily modify the database file
path = $smb_PATH
public = no
writable = yes
EOF
useradd $user
echo "����smb�˻�������"
# pdbedit -a -u $user #�н���
chown -Rf $user:$user /data/
 systemctl restart smb
 systemctl enable smb
/usr/bin/expect set timeout 100
spawn /usr/bin/pdbedit -a -u $user 
expect {
 "password" {send "${pass}\r";exp_continue}
 "password" {send "${pass}\r";}
}
expect eof
EOF
systemctl restart smb
systemctl status smb
}
#���
_check
#��ʼ��
_centos7_int
#��������
_info
#��װ
_smb_install