#!/bin/bash
#����ű�����һ����װ������samba
#���ߣ�www.cnbugs.com
#���ڣ�2018-12-17

if [ "$#" -ne 1 ]
then
    echo "���нű��ĸ�ʽΪ��$0 /dir/"
    exit 1
else
    if ! echo $1 |grep -q '^/.*'
    then
        echo "���ṩһ������·����"
        exit 1
    fi
fi

if ! rpm -q samba >/dev/null
then
    echo "��Ҫ��װsamba"
    sleep 1
    yum install -y samba
    if [ $? -ne 0 ]
    then
        echo "samba��װʧ��"
        exit 1
    fi
fi

cnfdir="/etc/samba/smb.conf"
cat >> $cnfdir <<EOF
[share]
        comment = share all
        path = $1
        browseable = yes
        public = yes
        writable = no
EOF

if [ ! -d $1 ]
then
    mkdir -p $1
fi

chmod 777 $1
echo "test" > $1/test.txt

#����ϵͳΪCentOS7
systemctl start smb
if [ $? -ne 0 ]
then
    echo "samba��������ʧ�ܣ����������ļ��Ƿ���ȷ��"
else
    echo "samba������ϣ�����֤��