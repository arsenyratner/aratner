/ip address add address=172.26.71.12/24 interface=ether1 network=172.26.71.0
/ip route add dst-address=0.0.0.0/0 gateway=172.26.71.1
/user/add name=aratner group=full disabled=no password="\$Qwerty2023"

:global WANIFDEFAULTNAME "ether1"
:global WANIFNAME "$WANIFDEFAULTNAME-WAN-vlan71";
:global LANIFDEFAULTNAME "ether2"
:global LANIFNAME "$LANIFDEFAULTNAME-LAN-222";
:global IDENTITY "i-rt2";
:global USERNAME "aratner";

/file print file="$USERNAME-key"
/file set "$USERNAME-key.txt" contents="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8z/rBphuDpGKHpcDtWDISCZFWybdH3fSKzVxWouLG0JuEhqZSpJT9Hd+16teA8daRPb1gY+l9+mRnCqTVDKxpnMq7jkjlfNKQPunDHhr3u7JDjeBel2JrgXs/GANMSbxyC5aRNP7XYs4TooRDUFr0XXvdglcYyP+34I0M+p9m94taK1q5FtL+JrpRXXGnhYzQn/GaV0rM9Qj21GFVWPfuqqG8wWwhaYPkeibJNhMcBy+qKRK0fIiklv68fWmIwd0Os9qEAJ4XTuVP8yfKR/Cu1hXPm/4+9JfXaw3Lh9e/J54NkRcyeT3wb0BgOpXMXnexl6HTUK59EcMaLGEaU+4F aratner@croc.ru"
/user ssh-keys import user=$USERNAME public-key-file="$USERNAME-key.txt"

/interface ethernet set [ find default-name=$WANIFDEFAULTNAME ] disable-running-check=no name=$WANIFNAME
#:log info "interface ethernet set [ find default-name=$WANIFDEFAULTNAME ] disable-running-check=no name=$WANIFNAME"
/interface ethernet set [ find default-name=$LANIFDEFAULTNAME ] disable-running-check=no mtu=1442 name=$LANIFNAME
/interface/print

/ip address add address=172.28.222.254/24 interface=$LANIFNAME network=172.28.222.0
/ip/address/print

/interface list add name=WAN
/interface list member add interface=$WANIFNAME list=WAN
/interface list add name=LAN
/interface list member add interface=$LANIFNAME list=LAN

/ip firewall address-list add address=10.10.12.51 list=trusted
/ip firewall address-list add address=172.26.71.12 list=trusted
/ip firewall address-list add address=172.26.71.13 list=trusted
/ip firewall address-list add address=172.28.221.0/24 list=trusted
/ip firewall address-list add address=172.28.222.0/24 list=trusted

/ip firewall filter add action=accept chain=input comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=input protocol=icmp
/ip firewall filter add action=accept chain=input connection-state=new src-address-list=trusted
/ip firewall filter add action=drop chain=input log-prefix=_IN_D_
/ip firewall filter add action=accept chain=forward comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=forward connection-state=new out-interface-list=WAN
/ip firewall filter add action=accept chain=forward connection-state=new dst-address-list=trusted src-address-list=trusted
/ip firewall filter add action=drop chain=forward log=yes log-prefix=_FW_D_
/ip firewall filter add action=accept chain=output comment="E, R" connection-state=established,related
/ip firewall filter add action=accept chain=output connection-state=new
/ip firewall filter add action=drop chain=output log=yes log-prefix=_OUT_D_
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN

/system clock set time-zone-name=Europe/Moscow
/system identity set name=$IDENTITY
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp server set enabled=yes
/system ntp client servers add address=ru.pool.ntp.org

/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip ssh set forwarding-enabled=both

/ip dns set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1,77.88.8.4

:global DHCPNETSHORT "222";
:global DHCPPOOLNAME "$DHCPNETSHORT-pool";
:global DHCPNET "172.28.$DHCPNETSHORT";
:global DHCPDOMNAME "aratner.ru";

/ip pool add name=$DHCPPOOLNAME ranges="$DHCPNET.100-$DHCPNET.199"
/ip dhcp-server network add address="$DHCPNET.0/24" dns-server="$DHCPNET.254" domain="$DHCPDOMNAME" gateway="$DHCPNET.254" netmask="24" ntp-server="$DHCPNET.254"
/ip dhcp-server add address-pool=$DHCPPOOLNAME disabled=yes interface=$LANIFNAME name=dhcp-server

/ip dhcp-server option sets add name=ad.aratner.ru options="*1,ad_4_timeserver,ad_6_dns,ad_15_domainname,ad_42_NTP Servers,ad_119_domain search"
/ip dhcp-server option sets add name=ad2.aratner.ru options="*1,ad_4_timeserver,ad2_6_dns,ad2_15_domainname,ad_42_NTP Servers"


/ip dhcp-server option add code=4 name=ad_4_timeserver value="'$DHCPNET.251'"
/ip dhcp-server option add code=6 name=ad_6_dns value="'$DHCPNET.251'"
/ip dhcp-server option add code=15 name=ad_15_domainname value="'ad.aratner.ru'"
/ip dhcp-server option add code=42 name="ad_42_NTP Servers" value="'$DHCPNET.251'"
/ip dhcp-server option add code=6 name=alt.nornik.ru_6_dns value="'$DHCPNET.241''$DHCPNET.242'"
/ip dhcp-server option add code=15 name=alt.nornik.ru_15_domainname value="'alt.nornik.ru'"
/ip dhcp-server option add code=4 name=alt.nornik.ru_4_timeserver value="'$DHCPNET.241''$DHCPNET.242'"
/ip dhcp-server option add code=6 name=ad2_6_dns value="'$DHCPNET.252'"
/ip dhcp-server option add code=15 name=ad2_15_domainname value="'ad2.aratner.ru'"
/ip dhcp-server option add code=4 name=alt.aratner.ru_4_timeserver value="'$DHCPNET.243''$DHCPNET.242'"
/ip dhcp-server option add code=6 name=alt.aratner.ru_6_dns value="'$DHCPNET.244'"
/ip dhcp-server option add code=15 name=alt.aratner.ru_15_domainname value="'alt.aratner.ru'"
/ip dhcp-server option add code=119 name="ad_119_domain search" value="'ad.aratner.ru'"
/ip dhcp-server option sets add name=alt.notnik.ru options=alt.nornik.ru_4_timeserver,alt.nornik.ru_6_dns,alt.nornik.ru_15_domainname
/ip dhcp-server option sets add name=alt.aratner.ru options=alt.aratner.ru_4_timeserver,alt.aratner.ru_6_dns,alt.aratner.ru_15_domainname



/ip dhcp-server lease add address=$DHCPNET.1 comment=aratner-rt1 mac-address=56:6F:D2:D4:00:7B
/ip dhcp-server lease add address=$DHCPNET.254 comment=aratner-rt2 mac-address=00:00:02:21:02:54
/ip dhcp-server lease add address=$DHCPNET.253 comment=aratner-c8-srv1 mac-address=56:6F:D2:D4:00:9A
/ip dhcp-server lease add address=$DHCPNET.3 comment=aratner-ws3 dhcp-option-set=alt.aratner.ru mac-address=56:6F:D2:D4:00:42
/ip dhcp-server lease add address=$DHCPNET.252 comment=aratner-dc2 dhcp-option-set=ad.aratner.ru mac-address=56:6F:D2:D4:00:3E
/ip dhcp-server lease add address=$DHCPNET.251 comment=aratner-dc1 mac-address=56:6F:D2:D4:00:3B
/ip dhcp-server lease add address=$DHCPNET.250 comment=aratner-dc3-d2 dhcp-option-set=ad.aratner.ru mac-address=56:6F:D2:D4:00:A2
/ip dhcp-server lease add address=$DHCPNET.243 comment=aratner-alt-dc3 dhcp-option-set=alt.aratner.ru mac-address=56:6F:D2:D4:01:08
/ip dhcp-server lease add address=$DHCPNET.4 comment=aratner-ws4-alt10 dhcp-option-set=alt.aratner.ru mac-address=56:6F:D2:D4:00:B2
/ip dhcp-server lease add address=$DHCPNET.244 comment=aratner-alt-dc4 dhcp-option-set=alt.aratner.ru mac-address=56:6F:D2:D4:01:03
/ip dhcp-server lease add address=$DHCPNET.5 comment=aratner-ws5-w10 dhcp-option-set=ad.aratner.ru mac-address=56:6F:D2:D4:00:7D
/ip dhcp-server lease add address=$DHCPNET.6 comment=aratner-ws6-w10 dhcp-option-set=alt.aratner.ru mac-address=56:6F:D2:D4:00:E4
/ip dhcp-server lease add address=$DHCPNET.7 comment=aratner-ws7-alt10 dhcp-option-set=alt.aratner.ru mac-address=56:6F:D2:D4:01:0E
/ip dhcp-server lease add address=$DHCPNET.199 comment=aratner-altnn-dctmp dhcp-option-set=alt.notnik.ru disabled=yes mac-address=56:6F:D2:D4:01:06
/ip dhcp-server lease add address=$DHCPNET.241 comment=aratner-altnn-dc1 dhcp-option-set=alt.notnik.ru disabled=yes mac-address=56:6F:D2:D4:01:04
/ip dhcp-server lease add address=$DHCPNET.8 comment=ws8-red7 mac-address=56:6F:D2:D4:01:0D
/ip dhcp-server lease add address=$DHCPNET.231 comment=aratner-red-fs1 dhcp-option-set=ad.aratner.ru mac-address=56:6F:D2:D4:00:48
/ip dhcp-server lease add address=$DHCPNET.232 comment=aratner-red-fs2 dhcp-option-set=ad.aratner.ru mac-address=56:6F:D2:D4:00:4B
/ip dhcp-server lease add address=$DHCPNET.233 comment=red-fs3 dhcp-option-set=ad.aratner.ru mac-address=56:6F:D2:D4:00:47
/ip dhcp-server lease add address=$DHCPNET.249 mac-address=56:6F:D2:D4:00:78
/ip dhcp-server lease add address=$DHCPNET.242 comment=alt-radius1 dhcp-option-set=alt.aratner.ru mac-address=56:6F:D2:D4:00:89
/ip dhcp-server lease add address=$DHCPNET.248 comment=alt-nipap1 mac-address=56:6F:D2:D4:00:CA


#/ip firewall nat add action=dst-nat chain=dstnat comment=aratner-ws3-w10 dst-port=30003 in-interface=$WANIFNAME protocol=tcp to-addresses=$DHCPNET.3 to-ports=3389
#/ip firewall nat add action=dst-nat chain=dstnat comment=aratner-ws4-alt10 dst-port=30004 in-interface=$WANIFNAME protocol=tcp to-addresses=$DHCPNET.4 to-ports=3389
#/ip firewall nat add action=dst-nat chain=dstnat comment=aratner-ws5 dst-port=30005 in-interface=$WANIFNAME protocol=tcp to-addresses=$DHCPNET.5 to-ports=3389
#/ip firewall nat add action=dst-nat chain=dstnat comment=aratner-ws6 dst-port=30006 in-interface=$WANIFNAME protocol=tcp to-addresses=$DHCPNET.6 to-ports=3389
#/ip firewall nat add action=dst-nat chain=dstnat comment=aratner-ws7 dst-port=30007 in-interface=$WANIFNAME protocol=tcp to-addresses=$DHCPNET.7 to-ports=3389
#/ip firewall nat add action=dst-nat chain=dstnat comment=aratner-dc4-alt10 dst-port=30249 in-interface=$WANIFNAME protocol=tcp to-addresses=$DHCPNET.249 to-ports=3389
#/ip firewall nat add action=dst-nat chain=dstnat comment=aratner-dc1 dst-port=30251 in-interface=$WANIFNAME protocol=tcp to-addresses=$DHCPNET.251 to-ports=3389
#/ip firewall nat add action=dst-nat chain=dstnat comment=aratner-dc2 dst-port=30252 in-interface=$WANIFNAME protocol=tcp to-addresses=$DHCPNET.252 to-ports=3389
