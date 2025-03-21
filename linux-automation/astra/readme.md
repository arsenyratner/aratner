# Заметки и шпаргалки по Astra Linux

## Сгенерить файл ответов с проинсталированной системы

взять инфу из файла /var/log/installer/cdebconf
```shell 
preseedcfg=/var/tmp/preseed.cfg
$ sudo chmod +rx /var/log/installer/cdebconf
$ echo "#_preseed_V1" > $preseedcfg
$ debconf-get-selections --installer >> $preseedcfg
$ debconf-get-selections >> $preseedcfg
```


## Подготовка шаблона. Установка с DVD

Разметка диска 9 GB:

устройство; точка монтирования; размер
/dev/sda1; /boot; 1 GB 
/dev/sda2; swap; 2 GB
/dev/sda3; /; (Всё что осталось)

```

Выбираем пакеты:
Fly desktop
Base packages
SSH server

Security LVL: Smolensk

```shell
cat > /etc/apt/sources.list<<EOF
deb https://download.astralinux.ru/astra/frozen/1.7_x86-64/1.7.6/uu/2/repository-base 1.7_x86-64 main contrib non-free
deb https://download.astralinux.ru/astra/frozen/1.7_x86-64/1.7.6/uu/2/repository-main 1.7_x86-64 main contrib non-free
deb https://download.astralinux.ru/astra/frozen/1.7_x86-64/1.7.6/uu/2/repository-extended 1.7_x86-64 main contrib non-free
deb https://download.astralinux.ru/astra/frozen/1.7_x86-64/1.7.6/uu/2/repository-update 1.7_x86-64 main contrib non-free
EOF

apt update; apt dist-upgrade -y 

apt install -y qemu-guest-agent spice-vdagent 

apt install -y cloud-guest-utils cloud-image-utils cloud-init

systemctl set-default multi-user.target
systemctl disable NetworkManager-wait-online.service NetworkManager.service
systemctl mask NetworkManager-wait-online.service NetworkManager.service
systemctl enable qemu-guest-agent

userdel -r -f astra

for nmcuuid in $(nmcli -t -f UUID,TYPE,NAME connection show | grep ethernet | awk -F":" '{ print $1 }'); do nmcli connection delete $nmcuuid; done; poweroff

```
