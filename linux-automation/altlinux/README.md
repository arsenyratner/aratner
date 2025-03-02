# altlinux шаблон с сайта альлинукс


## Спрашивать пароль пользователя, а не root 
В графике поумолчанию альт спрашивает пароль root а не пользователя, это меняет поведение и если пользователь в группе wheel он сможет ввести свой пароль чтобы подтвердить изменения, например в сетевом интерфейсе.
```shell
cat > /etc/polkit-1/rules.d/50-default.rules <<EOF
polkit.addAdminRule(function(action, subject) {
        return ["unix-group:wheel"];
});
EOF
```

## Настроить IP адрес NewtorkManager

```shell
ipv4_ifname="eth0"
ipv4_method="manual"
ipv4_address="172.26.76.227"
ipv4_mask="24"
ipv4_gateway="172.26.76.1"
ipv4_dnsservers="8.8.8.8 77.8.8.1"
ipv4_dnssearch="spo.local"
ipv6_method="disabled"

# удаляем netplan чтобы не мешал конфигурить NetworkManager
apt-get remove netplan -y
# удалить все подключения имя которых не совпадает с именем интерфейса
for nmcuuid in $(nmcli -t -f UUID,TYPE,NAME connection show | grep ethernet | awk -F":" '{ if ($3 != "'$ipv4_ifname'") print $1 }'); do echo "Removing connection uuid $nmcuuid"; nmcli connection delete $nmcuuid; done
# создадим подключение с названием интерфейса, если его не существует
nmcli con | grep -q $ipv4_ifname || nmcli connection add type ethernet ifname "$ipv4_ifname" con-name "$ipv4_ifname" autoconnect yes save yes
# настроим адрес ipv4
nmcli connection modify $ipv4_ifname ipv4.method "$ipv4_method" ipv4.addresses "$ipv4_address/$ipv4_mask" ipv4.gateway "$ipv4_gateway"
nmcli connection modify $ipv4_ifname ipv4.dns "$ipv4_dnsservers"
nmcli connection modify $ipv4_ifname ipv4.dns-search "$ipv4_dnssearch"
nmcli connection modify $ipv4_ifname ipv6.method "$ipv6_method"
nmcli connection down $ipv4_ifname; nmcli connection up $ipv4_ifname; 

```
