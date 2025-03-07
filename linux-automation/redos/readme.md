https://github.com/fflch/ansible-role-sambadc/blob/master/defaults/main.yml

```bash

cat > /usr/local/bin/netsetup.sh << EOF
#!/bin/bash

#variables
ipv4address="10.20.30.12"
ipv4mask="24"
ipv4gw="10.20.30.254"

# set password
echo redos | passwd redos --stdin

# Detect current connection name
nmconname=\$(nmcli -g name con | head -n1)
echo \${nmconname} | tee /tmp/nmconname

# detect device name
nmdevname=\$(ip -br l | awk '\$1 !~ "lo|vir|wl" { print \$1}')
echo \${nmdevname} | tee /tmp/nmdevname

# delete connections settings
rm -rf /etc/NetworkManager/system-connections/*

# Rename connection to device name
nmcli connection modify "\${nmconname}" connection.id \${nmdevname}

# NM set static ip 
nmcli connection modify \${nmdevname} IPv4.address \${ipv4address}/\${ipv4mask}
nmcli connection modify \${nmdevname} IPv4.gateway \${ipv4gw}
nmcli connection modify \${nmdevname} IPv4.method manual
nmcli connection reload
reboot
EOF

bash /usr/local/bin/netsetup.sh

```

#nmdevname=$(ip -br addr show to "$(nmcli -g ip6.address con show \"${nmconname}\")" | cut -d ' ' -f 1)
#ip -o addr show scope global | awk '/^[0-9]:/{print $2, $4}' | cut -f1 -d '/'
#ip -o addr show scope global | tr -s ' ' | tr '/' ' ' | cut -f 2,4 -d ' '
# nmcli connection modify $nmdevname IPv4.dns ${ipv4gw}

Правильно перезагружать
https://earlruby.org/2019/07/rebooting-a-host-with-ansible/

sudo grubby --update-kernel=ALL --args="video=hyperv_fb:1920x880"

systemctl get-default
sudo systemctl set-default multi-user.target
systemctl list-units --type target --all
sudo systemctl set-default graphical.target




```bash
IFNAME="System enp1s0"
IFADDR=172.28.221.4/24
IFGW=172.28.221.254
IFDNS="172.28.221.249"
IFDNSSUF="alt.nornik.ru"
#static
nmcli con mod  "$IFNAME" ipv4.addresses "$IFADDR"; \
nmcli con mod  "$IFNAME" ipv4.gateway "$IFGW"; \
nmcli con mod  "$IFNAME" ipv4.dns "$IFDNS"; \
nmcli con mod  "$IFNAME" ipv4.dns-search "$IFDNSSUF"; \
nmcli con mod  "$IFNAME" ipv4.method manual; \
nmcli con mod  "$IFNAME" connection.autoconnect yes; \
nmcli con mod  "$IFNAME" ipv6.method "disabled"; \
nmcli con down "$IFNAME"; nmcli con up "$IFNAME"

#dhcp
nmcli con mod  "$IFNAME" ipv4.addresses ""; \
nmcli con mod  "$IFNAME" ipv4.gateway ""; \
nmcli con mod  "$IFNAME" ipv4.dns ""; \
nmcli con mod  "$IFNAME" ipv4.dns-search ""; \
nmcli con mod  "$IFNAME" connection.autoconnect yes; \
nmcli con mod  "$IFNAME" ipv4.method auto; \
nmcli con mod  "$IFNAME" ipv6.method "disabled"; \
nmcli con down "$IFNAME"; nmcli con up "$IFNAME"

```