# new dc
## переменные 
```
domname=alt.aratner.ru
domshortname=alt
domuser=administrator
domuserpass=QAZxsw123
domhostname=alt-dc4
#etcnet static ip
ifname=enp1s0
ipaddress=172.28.221.244
mask=24
dnsserver1="172.28.221.254"
defaultgw="192.168.126.1"
### переменные add dc
domdcname=alt-dc3
```
## настройка сети
```
hostnamectl set-hostname $domhostname.$domname
#disable ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -f
#etcnet static ip
cat > /etc/net/ifaces/${ifname}/options <<EOF
DISABLED=no
BOOTPROTO=static
ONBOOT=yes
CONFIG_IPV4=yes
TYPE=eth
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF
echo "${ipaddress}/${mask}" > /etc/net/ifaces/${ifname}/ipv4address
echo "default via ${defaultgw}"> /etc/net/ifaces/${ifname}/ipv4route
echo domain \"$domname\" > /etc/net/ifaces/${ifname}/resolv.conf
echo nameserver \"$dnsserver1\" >> /etc/net/ifaces/${ifname}/resolv.conf
#apply network settings
/etc/init.d/network restart 
```
## устанавливаем все обновления и нужные пакеты
```
apt-get update; apt-get dist-upgrade -y; update-kernel -y; apt-get clean
apt-get update; apt-get install -y task-samba-dc packagekit cifs-utils bind-utils chrony bind
systemctl enable --now chronyd
#перезагружаемся
reboot
```
## Создаём новые домен на новом контроллере
```
#подготовка для samba dc
rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba/*
rm -rf /var/cache/samba/*
mkdir -p /var/lib/samba/sysvol

#добавить контроллер в существующий домен с ДНС сервисом в bind
#samba-tool dns add $domdcname $domname $domhostname A $ipaddress -U ${domshortname}\\${domuser}%${domuserpass}
#samba-tool domain join $domname DC --realm=$domname --dns-backend=BIND9_DLZ -U${domshortname}\\${domuser}%${domuserpass}

#новый контроллер в новый домен с ДНС сервисом в bind
samba-tool domain provision --realm=$domname --domain=$domshortname --adminpass=$domuserpass --dns-backend=BIND9_DLZ --server-role=dc
```
## донсатроим bind
```
#bind должен дождаться запуска сети
#vim /lib/systemd/system/bind.service
#After=network.target network-online.target
systemctl daemon-reload
#отключим chroot
sed -i '/CHROOT=/s/^#//g' /etc/sysconfig/bind

#закоментируем chcon ... чтобы можно было включить named.txt в конфиг bind options
sed -i '/^chcon/s/^/#/g' /var/lib/samba/bind-dns/named.txt

#создадим options.conf
cat > /etc/bind/options.conf <<EOF
options {
        version "unknown";
        directory "/etc/bind/zone";
        dump-file "/var/run/named_dump.db";
        statistics-file "/var/run/named.stats";
        recursing-file "/var/run/recursing";
        pid-file none;
        listen-on { any; };
        listen-on-v6 { ::1; };
        allow-query { any; };
        allow-query-cache { any; };
        allow-recursion { any; };
        //max-cache-ttl 86400;
        include "/var/lib/samba/bind-dns/named.txt";
        dnssec-validation no;
        forwarders { ${dnsserver1}; };
};
EOF

#добавим параметры загрузки зон из самбы
echo include \"/var/lib/samba/bind-dns/named.conf\"\; >> /etc/bind/named.conf
#пусть самба не занимает 53 порт
sed -i 's/server services.*$/server services = -dns/g' /etc/samba/smb.conf
#запустим сервисы
systemctl enable --now samba
systemctl enable --now bind 
```
## настроим днс клиент на доменконтроллеры
```
#переменные
ifname=enp1s0
dnsserver1="127.0.0.1"
#dnsserver2="172.28.221.243"
#dns 
echo domain \"$domname\" > /etc/net/ifaces/${ifname}/resolv.conf
echo nameserver \"$dnsserver1\" >> /etc/net/ifaces/${ifname}/resolv.conf
#echo nameserver \"$dnsserver2\" >> /etc/net/ifaces/${ifname}/resolv.conf
/etc/init.d/network restart
```
