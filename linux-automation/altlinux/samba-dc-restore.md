# tmpdc
## переменные
```
domname=alt.nornik.ru
domshortname=alt
domuser=administrator
domuserpass=QAZxsw123
domhostname=ara-altnn-dctmp
### переменные etcnet static ip
ifname=enp1s0
ipaddress=172.28.221.199
mask=24
dnsserver1="172.28.221.254"
targetdir=/var/lib/samba-20230814-3
backupfile=/var/backup/samba-backup-alt.nornik.ru-2023-08-14T14-12-58.765843.tar.bz2
```

## networksettings
```
hostnamectl set-hostname $domhostname.$domname

## disable ipv6
#вариант 1
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -f
#вариант 3
#echo 'options ipv6 disable=1' >> /etc/modprobe.d/options-local.conf

## etcnet static ip
#options
cat > /etc/net/ifaces/${ifname}/options <<EOF
DISABLED=no
BOOTPROTO=static
ONBOOT=yes
CONFIG_IPV4=yes
TYPE=eth
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF
#ip address
echo "${ipaddress}/${mask}" > /etc/net/ifaces/${ifname}/ipv4address
#routes
echo "default via 172.28.221.254"> /etc/net/ifaces/${ifname}/ipv4route
#dns 
echo domain \"$domname\" > /etc/net/ifaces/${ifname}/resolv.conf
echo nameserver \"$dnsserver1\" >> /etc/net/ifaces/${ifname}/resolv.conf
#apply 
/etc/init.d/network restart
```
## устанавливаем все обновления, необходимые пакеты и перезагружаемся
```
apt-get update; apt-get dist-upgrade -y; update-kernel -y; apt-get clean
apt-get update; apt-get install -y task-samba-dc packagekit cifs-utils bind-utils chrony
systemctl enable --now chronyd
reboot
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
#делаем доступ на восстановленную папку 755 иначе sysvol шара не будет открываться
chmod 755 ${targetdir}
#делаем ссылку на папку таргет   
rm -rf /var/lib/samba
ln -s ${targetdir} /var/lib/samba
#копируем настройки керберос
yes | cp -rf ${targetdir}/private/krb5.conf /etc/krb5.conf
#кладём конфиг самбы на стандартное место
ln -s ${targetdir}/etc/smb.conf /etc/samba/smb.conf
#включим DNS сервере в самбе и настроим форвард
vim ${targetdir}/etc/smb.conf
#запустим самбу в интерактивнмо режими
samba -s ${targetdir}/etc/smb.conf -i -d 3
```
## Добавим NS записи в зоны в которых её не оказалось после восстановления
```
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
## После того как добавили боевые контроллеры в восстановленный домен понизим временный контроллер
```
#demote
samba-tool domain demote -U ${domuser}@${domname^^}%${domuserpass}
```
