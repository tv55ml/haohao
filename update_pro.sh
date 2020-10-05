#!/bin/bash
is_samba_installed=`rpm -qa|grep samba|wc -l`
if [ $is_samba_installed != 0 ]
then
    echo "You had already installed Samba."
    exit 0
fi
echo "It will install Samba."
sleep 1
cnfdir="/etc/samba/smb.conf"
chkok(){
    if [ $? != 0 ]
    then
        echo "Error, Please try again."
        exit 1
    fi
}
yum install -y samba
chkok
sed -i 's/MYGROUP/WORKGROUP/' $cnfdir
sed -i 's/user/share/' $cnfdir
sed -i '$a\[fish]' $cnfdir
if [ -d $1 ]
then
    cd $1
    echo "test" &gt; test.txt
    sed -i '$a\[fish]\n\tcomment = Share All\n\tpath = "'$1'"\n\tbrowseable = yes\n\tpublic = yes\n\twritable = no' $cnfdir
else
    mkdir $1
    cd $1
    echo "test" &gt; test.txt
    sed -i '$a\[fish]\n\tcomment = Share All\n\tpath = "'$1'"\n\tbrowseable = yes\n\tpublic = yes\n\twritable = no' $cnfdir
fi
/etc/init.d/smb start
chkok
echo "Please input [\\sambaIP\sharename] to access the share dir."