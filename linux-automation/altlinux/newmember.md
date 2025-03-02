# new member
## переменные 
```
domname=alt.aratner.ru
domshortname=alt
domuser=administrator
domuserpass=QAZxsw123
domhostname=alt-ws7
domdcname=alt-dc4

apt-get update; apt-get dist-upgrade -y; update-kernel -y; apt-get clean
apt-get update; apt-get install -y task-auth-ad-sssd packagekit gpupdate adp alterator-auth alterator-gpupdate
hostnamectl set-hostname $domhostname.$domname
reboot

rm -rf /home/${domname^^}/*
system-auth write local
rm -rf /etc/krb5.keytab
system-auth write ad $domname $domhostname $domshortname $domuser $domuserpass
gpupdate-setup write enable workstation
```
