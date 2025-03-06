# VPN

## IKEV2
```shell
sudo apt install -y strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins libstrongswan-extra-plugins


mv /etc/ipsec.conf{,.original}
cat /etc/ipsec.conf << EOF
# ipsec.conf - strongSwan IPsec configuration file
# basic configuration

config setup
    # strictcrlpolicy=yes
    # uniqueids = yes
    uniqueids = never
    # charondebug="ike 2, knl 2, cfg 2, net 2, esp 2, dmn 2,  mgr 2"

conn common
    auto=add
    compress=no
    type=tunnel

    keyexchange=ike
    ike=aes128-sha1-modp1024,aes128-sha1-modp1536,aes128-sha1-modp2048,aes128-sha256-ecp256,aes128-sha256-modp1024,aes128-sha256-modp1536,aes128-sha256-modp2048,aes256-aes128-sha256-sha1-modp2048-modp4096-modp1024,aes256-sha1-modp1024,aes256-sha256-modp1024,aes256-sha256-modp1536,aes256-sha256-modp2048,aes256-sha256-modp4096,aes256-sha384-ecp384,aes256-sha384-modp1024,aes256-sha384-modp1536,aes256-sha384-modp2048,aes256-sha384-modp4096,aes256gcm16-aes256gcm12-aes128gcm16-aes128gcm12-sha256-sha1-modp2048-modp4096-modp1024,3des-sha1-modp1024!
    esp=aes128-aes256-sha1-sha256-modp2048-modp4096-modp1024,aes128-sha1,aes128-sha1-modp1024,aes128-sha1-modp1536,aes128-sha1-modp2048,aes128-sha256,aes128-sha256-ecp256,aes128-sha256-modp1024,aes128-sha256-modp1536,aes128-sha256-modp2048,aes128gcm12-aes128gcm16-aes256gcm12-aes256gcm16-modp2048-modp4096-modp1024,aes128gcm16,aes128gcm16-ecp256,aes256-sha1,aes256-sha256,aes256-sha256-modp1024,aes256-sha256-modp1536,aes256-sha256-modp2048,aes256-sha256-modp4096,aes256-sha384,aes256-sha384-ecp384,aes256-sha384-modp1024,aes256-sha384-modp1536,aes256-sha384-modp2048,aes256-sha384-modp4096,aes256gcm16,aes256gcm16-ecp384,3des-sha1!

    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no

    left=%any
    #leftid=@vpn.ratners.online
    #leftcert=vpn.ratners.online.fullchain.pem
    leftid=@r-vm-vpn1.r.ratners.ru
    leftcert=r-vm-vpn1.r.ratners.ru.fullchain.pem
    leftsendcert=always
    leftsubnet=192.168.126.0/24,0.0.0.0/0
    right=%any
    rightid=%any
    rightsourceip=192.168.116.0/24
    rightdns=192.168.126.2,192.168.126.3
    rightsendcert=never

conn ikev2-eap
    also=common
    auto=add
    keyexchange=ikev2
    rightauth=eap-mschapv2
    eap_identity=%identity

conn ikev1-xauth
    also=common
    auto=add
    keyexchange=ikev1
    rightauth=xauth

#mikrotik ipsec interface
conn r126
    fragmentation=yes
    dpdaction=restart
    type=transport
    keyingtries=%forever
    ike=aes128-sha1-modp2048
    esp=aes128-sha1-modp1024
    keyexchange=ikev1
    left=95.217.218.224
    leftauth=psk
    leftprotoport=4
    right=95.165.88.186
    rightauth=psk
    rightprotoport=4
    auto=route
EOF

cat /etc/ipsec.secrets << EOF
cat ipsec.secrets
# ipsec.secrets - strongSwan IPsec secrets file
95.217.218.224 95.165.88.186 : PSK "yojwashkasPheorcIrf5"
: RSA "r-vm-vpn1.r.ratners.ru.privkey.pem"
appc : EAP "Savvoyct7"
stopthewar : EAP "yorrOtNov3"
ov : EAP "Grifsuk3"
dv : EAP "dyWamud7"
dr : EAP "Dr5450Rd"
ya : EAP "Dokentigg8"
gr : EAP "Galuna22"
nn : EAP "vickauWef2"
EOF

## firewall
ufw allow OpenSSH
ufw enable
ufw allow 500,4500/udp

# /etc/ufw/before.rules

*filter
-A ufw-before-forward --match policy --pol ipsec --dir in --proto esp -s 192.168.116.0/24 -j ACCEPT
-A ufw-before-forward --match policy --pol ipsec --dir out --proto esp -d 192.168.116.0/24 -j ACCEPT

*nat
-A POSTROUTING -s 192.168.116.0/24 -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
-A POSTROUTING -s 192.168.116.0/24 -o eth0 -j MASQUERADE
COMMIT

*mangle
-A FORWARD --match policy --pol ipsec --dir in -s 192.168.116.0/24 -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360



#/etc/ufw/sysctl.conf
net/ipv4/ip_forward=1
net/ipv4/conf/all/accept_redirects=0
net/ipv4/conf/all/send_redirects=0
net/ipv4/ip_no_pmtu_disc=1

ufw disable
ufw enable

cp -f /etc/letsencrypt/live/r-vm-vpn1.r.ratners.ru/chain.pem /etc/ipsec.d/cacerts/r-vm-vpn1.r.ratners.ru.chain.pem
cp -f /etc/letsencrypt/live/r-vm-vpn1.r.ratners.ru/privkey.pem /etc/ipsec.d/private/r-vm-vpn1.r.ratners.ru.privkey.pem
cp -f /etc/letsencrypt/live/r-vm-vpn1.r.ratners.ru/cert.pem  /etc/ipsec.d/certs/r-vm-vpn1.r.ratners.ru.cert.pem
cp -f /etc/letsencrypt/live/r-vm-vpn1.r.ratners.ru/fullchain.pem /etc/ipsec.d/certs/r-vm-vpn1.r.ratners.ru.fullchain.pem

```