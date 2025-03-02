# tmpdc
## переменные
```
domname=red.aratner.ru
domshortname=red
domuser=administrator
domuserpass=NenDilvUn6
domhostname=red-tempdc

### переменные etcnet static ip
dnsserver1="10.20.30.21"
targetdir=/var/lib/samba
backupfile=/var/tmp/samba-backup-2024-03-01T14-12-15.807600.tar.bz2

```

## networksettings
```
hostnamectl set-hostname $domhostname.$domname
```
# Восстановление
## удаляем конфиг самбы, каэш и файлы данных
```
#for service in samba smb nmb krb5kdc slapd bind; do systemctl disable --now $service; done
rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba/*
rm -rf /var/cache/samba/*
rm -rf $targetdir
```
## восстанавилваемся из резервной копии и донастраиваем самбу после восстановления
```
samba-tool domain backup restore --newservername=${domhostname} --targetdir=${targetdir} --backup-file=$backupfile --debuglevel=3

cat > /etc/resolv.conf <<EOF
search ${domname}
nameserver ${dnsserver1}
EOF

#копируем настройки керберос
yes | cp -rf ${targetdir}/private/krb5.conf /etc/krb5.conf
#запустим самбу в интерактивнмо режими
samba -s ${targetdir}/etc/smb.conf -i -d 3
```
## Добавим NS записи в зоны в которых её не оказалось после восстановления
```
samba_upgradedns --dns-backend=SAMBA_INTERNAL -U admin.ratner%QAZxsw123 -s /var/lib/samba/etc/smb.conf

samba-tool dns add red-tempdc red.aratner.ru red-tempdc A 10.20.30.21 -Uadmin.ratner%QAZxsw123
samba-tool dns add red-tempdc red.aratner.ru @ A 10.20.30.21 -Uadmin.ratner%QAZxsw123

#добавим NS запись во все зоны где её нет
for zone in $(samba-tool dns zonelist $domhostname -U ${domuser}%${domuserpass} -d 0| grep pszZoneName | awk -F: '{ gsub(" ","",$0); print $2 }'); 
do 
  echo "checking $zone"; 
  #samba-tool dns query $domhostname $zone @ NS -U${domuser}%${domuserpass} -d 0 | grep NS:
  if ! samba-tool dns query $domhostname $zone @ NS -U${domuser}%${domuserpass} -d 0 | grep NS: > /dev/null; then  
    echo "no NS record in $zone, creating"
    samba-tool dns add $domhostname $zone @ NS ${domhostname}.${domname}. -U${domuser}%${domuserpass} -d 0
  fi
done
```
## Донастроим ДНС клиент на временном сервере
```
#dns client
dnsserver1="127.0.0.1"
echo domain \"$domname\" > /etc/net/ifaces/${ifname}/resolv.conf
echo nameserver \"$dnsserver1\" >> /etc/net/ifaces/${ifname}/resolv.conf
#apply 
/etc/init.d/network restart
```
## Добавляем контроллер
cat > /etc/resolv.conf <<EOF
search ${domname}
nameserver ${dnsserver1}
EOF

rm -f /etc/samba/smb.conf* /etc/krb5.conf
rm -rf /var/lib/samba/*

#ВАЖНО Положение учётных данных важнО! 
samba-tool domain join red.aratner.ru DC -U RED\\admin.ratner%QAZxsw123 --dns-backend=BIND9_DLZ --realm=RED.ARATNER.RU


## После того как добавили боевые контроллеры в восстановленный домен понизим временный контроллер
```
#demote
samba-tool domain demote -U ${domuser}@${domname^^}%${domuserpass}
```
