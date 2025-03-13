# Настройка routeros

https://yetiops.net/posts/ansible-for-networking-part-6-mikrotik-routeros/


## Подготовка рабочего окружения

Добавим недостающие пакеты

ansible-pylibssh - нужен чтобы работал network_cli через джампы

```bash
apt-get install -y pip
pip install ansible-pylibssh
ansible-galaxy collection install ansible.netcommon community.routeros

```

Настроим SSH джам

```
Host jump_rt0
    User aratner
    IdentityFile ~/.ssh/croc

Host 172.23.95.46
    ProxyJump jump_rt0
    User croc
    IdentityFile ~/.ssh/croc
```

Минимальная конфигурация, всё остальное будем настраивать плейбуками

```
/ip address add address=172.26.76.217/24 interface=ether1-WAN network=172.26.76.0
/ip route add dst-address=0.0.0.0/0 gateway=172.26.76.1
/user add group=full name=croc password=QAZxsw123

```

Остальное катим плейбуком

```
/interface ethernet set [ find default-name=ether1 ] disable-running-check=no name=ether1-WAN
/interface ethernet set [ find default-name=ether2 ] disable-running-check=no mtu=1442 name=ether2-LAN-212
/interface ethernet set [ find default-name=ether3 ] disable-running-check=no mtu=1442 name=ether3-LAN-213
/interface ethernet set [ find default-name=ether4 ] disable-running-check=no mtu=1442 name=ether4-LAN-214
/interface ethernet set [ find default-name=ether5 ] disable-running-check=no mtu=1442 name=ether5-LAN-215

/interface list add name=WAN
/interface list add name=LAN
/interface list member add interface=ether1-WAN list=WAN
/interface list member add interface=ether5-LAN-215 list=LAN
/interface list member add interface=ether4-LAN-214 list=LAN
/interface list member add interface=ether3-LAN-213 list=LAN
/interface list member add interface=ether2-LAN-212 list=LAN

/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes

/ip firewall address-list add address=10.10.12.51 list=trusted
/ip firewall address-list add address=172.28.208.0/22 disabled=yes list=trusted
/ip firewall address-list add address=172.28.212.0/22 list=trusted


/ip firewall filter add action=accept chain=input comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=input protocol=icmp
/ip firewall filter add action=accept chain=input connection-state=new src-address-list=trusted
/ip firewall filter add action=drop   chain=input log=yes log-prefix=_D_in_

/ip firewall filter add action=accept chain=forward comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=forward comment=DNATed connection-nat-state=dstnat connection-state=new in-interface-list=WAN
/ip firewall filter add action=accept chain=forward comment=lan_internetallow connection-state=new out-interface-list=WAN src-address-list=lan_internetallow
/ip firewall filter add action=accept chain=forward connection-state=new dst-address-list=trusted src-address-list=trusted
/ip firewall filter add action=accept chain=forward connection-state="" dst-address-list=trusted log=yes log-prefix=_FW_T_ src-address-list=trusted
/ip firewall filter add action=drop   chain=forward log=yes log-prefix=_FW_D_

/ip firewall filter add action=accept chain=output comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=output connection-state=new
/ip firewall filter add action=drop   chain=output log=yes log-prefix=_OUT_D_

/ip firewall nat add action=accept chain=srcnat dst-address-list=trusted src-address-list=trusted
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN



/ipv6 settings set disable-ipv6=yes max-neighbor-entries=3072


/ip dns set allow-remote-requests=yes servers=8.8.8.8,77.88.8.4



/ip ssh set forwarding-enabled=both

# /routing ospf instance add disabled=no name=ospf-instance-1 originate-default=always redistribute=connected,static,vpn routing-table=main
# /routing ospf area add disabled=no instance=ospf-instance-1 name=ospf-area-1
# /routing ospf interface-template add area=ospf-area-1 disabled=no interfaces=ether1-WAN networks=172.26.71.0/24

/system clock set time-zone-name=Europe/Moscow

/system identity set name=rt1

/system ntp client set enabled=yes
/system ntp server set enabled=yes
/system ntp client servers add address=ru.pool.ntp.org

```

/ip firewall mangle add action=add-src-to-address-list address-list=r-gw1 address-list-timeout=8s chain=prerouting comment="sstp 443" connection-state="" dst-address-type=local dst-port=443 protocol=tcp tls-host=r-gw1.ratners.ru
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark in-interface=vlan3-WAN-mgts new-connection-mark=mgts passthrough=no
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark in-interface=ipip-r-prx-01 new-connection-mark=r-prx-01 passthrough=no
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=mgts dst-address-list=!localnet in-interface=!vlan3-WAN-mgts log-prefix=_M_mr_ new-routing-mark=mgts passthrough=no
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=mgts in-interface=!vlan3-WAN-mgts log=yes log-prefix=_M_mr_ new-routing-mark=mgts passthrough=no
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=r-prx-01 dst-address-list=!localnet in-interface=!ipip-r-prx-01 log-prefix=_M_mr_ new-routing-mark=r-prx-01 passthrough=no
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=r-prx-01 in-interface=!ipip-r-prx-01 log=yes log-prefix=_M_mr_ new-routing-mark=r-prx-01 passthrough=no
/ip firewall mangle add action=mark-routing chain=output connection-mark=mgts new-routing-mark=mgts passthrough=no
/ip firewall mangle add action=mark-routing chain=output connection-mark=r-prx-01 new-routing-mark=r-prx-01 passthrough=no

/ip firewall nat add action=masquerade chain=srcnat comment=nat-loopback log-prefix=nat-loopback packet-mark=nat-loopback
/ip firewall nat add action=masquerade chain=srcnat comment="defconf: masquerade" out-interface=vlan3-WAN-mgts
/ip firewall nat add action=dst-nat chain=dstnat dst-address-list=wanip dst-port=5201 protocol=tcp src-address-list=trusted_ip to-addresses=192.168.126.5
/ip firewall nat add action=dst-nat chain=dstnat comment="appc-pc RDP" dst-address-list=wanip dst-port=3389 log-prefix=_RDP_ protocol=tcp src-address-list=trusted_ip to-addresses=192.168.126.5
/ip firewall nat add action=dst-nat chain=dstnat comment="appc-pc qbittorrent" dst-address-list=wanip dst-port=13955 log-prefix=_qbittorrent protocol=tcp to-addresses=192.168.126.53 to-ports=13955
/ip firewall nat add action=dst-nat chain=dstnat comment="appc-pc ftp" disabled=yes dst-address-list=wanip dst-port=50021 protocol=tcp to-addresses=192.168.126.5 to-ports=21
/ip firewall nat add action=dst-nat chain=dstnat comment="appc-pc frp" disabled=yes dst-address-list=wanip dst-port=7000-7100 protocol=tcp to-addresses=192.168.126.5
/ip firewall nat add action=dst-nat chain=dstnat comment="nginx proxy manager" dst-address-list=wanip dst-port=80 log-prefix=_HTTP_ protocol=tcp to-addresses=192.168.126.10 to-ports=80
/ip firewall nat add action=dst-nat chain=dstnat comment="nginx proxy manager" dst-address-list=wanip dst-port=443 log-prefix=_HTTPS_ protocol=tcp to-addresses=192.168.126.10