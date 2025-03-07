# Openconnect server
```shell
ufw allow OpenSSH
ufw status

apt install -y ocserv

ufw allow 443
ufw allow 443/udp

mv /etc/ocserv/ocserv.conf{,.original}

ocpasswd --passwd=/etc/ocserv/ocserv.passwd appc

echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.d/60-custom.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/60-custom.conf
sudo sysctl -p /etc/sysctl.d/60-custom.conf

#/etc/ufw/before.rules
*nat
-A POSTROUTING -s 192.168.115.0/24 -o eth0 -j MASQUERADE

-A ufw-before-forward -s 192.168.115.0/24 -j ACCEPT
-A ufw-before-forward -d 192.168.115.0/24 -j ACCEPT

```
