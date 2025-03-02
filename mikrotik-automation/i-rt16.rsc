#команды которые необходимо ввести в терминале ВМ
/ip address add address=172.26.71.16/24 interface=ether2
/ip route add dst-address=0.0.0.0/0 gateway=172.26.71.1
/ip/dhcp-client/disable ether1

#команды которые можно ввести из SSH
:global WANIFDEFAULTNAME "ether2"
:global LANIFDEFAULTNAME "ether1"
:global WANIFNAME "$WANIFDEFAULTNAME-WAN-vlan71";
:global LANIFNAME "$LANIFDEFAULTNAME-LAN-16";
:global IDENTITY "i-rt16";
:global USERNAME "aratner";
:global LANIPADDR "172.28.16.1";
:global LANIPMASK "24";
:global LANNET "172.28.16.0/24";


:global source    $LANIPADDR
{
:global ip        [:toip [:pick $source 0 [:find $source "/"]]]
:global prefix    [:tonum [:pick $source ([:find $source "/"] + 1) [:len $source]]]
:global submask   (255.255.255.255<<(32 - $prefix))
:global addrspace (~$submask)
:global totip     ([:tonum $addrspace] + 1)
:global network   ($ip & $submask)
:global broadcast ($ip | $addrspace)
:global first     (($network + 1) - ($prefix / 31))
:global last      (($broadcast - 1) + ($prefix / 31))
:global usable    (($last - $network) + ($prefix / 31))
:global poolrange "$(($network + 2) - ($prefix / 31))-$(($broadcast - 2) + ($prefix / 31))"
}

:log info "user password ssh key"
/user/add name=$USERNAME group=full disabled=no password="QAZxsw123"
/file print file="$USERNAME-key"
/file set "$USERNAME-key.txt" contents="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8z/rBphuDpGKHpcDtWDISCZFWybdH3fSKzVxWouLG0JuEhqZSpJT9Hd+16teA8daRPb1gY+l9+mRnCqTVDKxpnMq7jkjlfNKQPunDHhr3u7JDjeBel2JrgXs/GANMSbxyC5aRNP7XYs4TooRDUFr0XXvdglcYyP+34I0M+p9m94taK1q5FtL+JrpRXXGnhYzQn/GaV0rM9Qj21GFVWPfuqqG8wWwhaYPkeibJNhMcBy+qKRK0fIiklv68fWmIwd0Os9qEAJ4XTuVP8yfKR/Cu1hXPm/4+9JfXaw3Lh9e/J54NkRcyeT3wb0BgOpXMXnexl6HTUK59EcMaLGEaU+4F aratner@croc.ru"
/user ssh-keys import user=$USERNAME public-key-file="$USERNAME-key.txt"
/user/disable admin

:log info "if name ip address"
/interface ethernet set [ find default-name=$WANIFDEFAULTNAME ] disable-running-check=no name=$WANIFNAME
/interface ethernet set [ find default-name=$LANIFDEFAULTNAME ] disable-running-check=no mtu=1442 name=$LANIFNAME
/ip address add address="$LANIPADDR/$LANIPMASK" interface=$LANIFNAME
/ip dns set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1,77.88.8.4

:log info "fw rules"
/interface list add name=WAN
/interface list member add interface=$WANIFNAME list=WAN
/interface list add name=LAN
/interface list member add interface=$LANIFNAME list=LAN

/ip firewall address-list add address=10.10.12.51 list=trusted
/ip firewall address-list add address=172.26.71.12/30 list=trusted
/ip firewall address-list add address=172.26.71.16 list=trusted
/ip firewall address-list add address=172.26.71.17 list=trusted
/ip firewall address-list add address=172.28.12.0/22 list=trusted
/ip firewall address-list add address=172.28.16.0/24 list=trusted
/ip firewall address-list add address=172.28.17.0/24 list=trusted

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

:log info "identity ntp"
/system clock set time-zone-name=Europe/Moscow
/system identity set name=$IDENTITY
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp server set enabled=yes
/system ntp client servers add address=ru.pool.ntp.org

:log info "remote admin"
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip ssh set forwarding-enabled=both
/ip/ssh/set always-allow-password-login=no

/ip pool add name=dhcp-pool ranges=$poolrange
/ip dhcp-server add address-pool=dhcp-pool disabled=no interface=$LANIFNAME name=dhcp-server
/ip dhcp-server network add address=$LANNET dns-server=$LANIPADDR domain=$DOMAIN gateway=$LANIPADDR netmask=$prefix ntp-server=$LANIPADDR
