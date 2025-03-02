# 2024-01-15 16:58:57 by RouterOS 7.13.1
# software id = 
#
/disk set slot1 slot=slot1 type=hardware
/disk set slot2 slot=slot2 type=hardware
/disk set slot3 slot=slot3 type=hardware
/disk set slot4 slot=slot4 type=hardware
/disk set slot5 slot=slot5 type=hardware
/disk set slot6 slot=slot6 type=hardware
/disk set slot7 slot=slot7 type=hardware
/disk set slot8 slot=slot8 type=hardware
/disk set slot9 slot=slot9 type=hardware
/disk set slot10 slot=slot10 type=hardware
/disk set slot11 slot=slot11 type=hardware
/disk set slot12 slot=slot12 type=hardware
/disk set slot13 slot=slot13 type=hardware
/interface ethernet set [ find default-name=ether1 ] disable-running-check=no name=ether1-WAN-vlan71
/interface ethernet set [ find default-name=ether2 ] disable-running-check=no mtu=1442 name=ether2-LAN-12
/interface list add name=WAN
/interface list add name=LAN
/ip pool add name=222-pool ranges=172.28.222.100-172.28.222.199
/ip dhcp-server add address-pool=222-pool disabled=yes interface=ether2-LAN-12 name=dhcp-server
/interface list member add interface=ether1-WAN-vlan71 list=WAN
/interface list member add interface=ether2-LAN-12 list=LAN
/ip address add address=172.26.71.12/24 interface=ether1-WAN-vlan71 network=172.26.71.0
/ip address add address=172.28.12.254/24 interface=ether2-LAN-12 network=172.28.12.0
/ip dhcp-client add default-route-distance=100 disabled=yes interface=ether2-LAN-12
/ip dhcp-client add disabled=yes interface=ether1-WAN-vlan71
/ip dhcp-server network add address=172.28.222.0/24 dns-server=172.28.222.254 domain=aratner.ru gateway=172.28.222.254 netmask=24 ntp-server=172.28.222.254
/ip dns set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1,77.88.8.4
/ip firewall address-list add address=10.10.12.51 list=trusted
/ip firewall address-list add address=172.26.71.12 list=trusted
/ip firewall address-list add address=172.26.71.13 list=trusted
/ip firewall address-list add address=172.28.13.0/24 list=trusted
/ip firewall address-list add address=172.28.12.0/24 list=trusted
/ip firewall filter add action=accept chain=input comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=input protocol=icmp
/ip firewall filter add action=accept chain=input connection-state=new src-address-list=trusted
/ip firewall filter add action=drop chain=input log-prefix=_IN_D_
/ip firewall filter add action=accept chain=forward comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=forward comment=DNAT connection-nat-state=dstnat connection-state=new
/ip firewall filter add action=accept chain=forward connection-state=new dst-address-list=trusted src-address-list=trusted
/ip firewall filter add action=accept chain=forward connection-state=new out-interface-list=WAN
/ip firewall filter add action=drop chain=forward log=yes log-prefix=_FW_D_
/ip firewall filter add action=accept chain=output comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=output connection-state=new
/ip firewall filter add action=drop chain=output log=yes log-prefix=_OUT_D_
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/ip firewall nat add action=dst-nat chain=dstnat dst-address=172.26.71.12 dst-port=30253 protocol=tcp to-addresses=172.28.12.253 to-ports=3389
/ip route add dst-address=0.0.0.0/0 gateway=172.26.71.1
/ip route add disabled=no distance=1 dst-address=172.28.13.0/24 gateway=172.26.71.13 pref-src="" routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip ssh set forwarding-enabled=both
/system clock set time-zone-name=Europe/Moscow
/system identity set name=i-rt12
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp server set enabled=yes
/system ntp client servers add address=ru.pool.ntp.org
/system script add dont-require-permissions=no name=setup.rsc owner=appc policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=""
