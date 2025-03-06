lang en_US --addsupport=ru_RU
keyboard --xlayouts='us'
timezone Europe/Moscow --utc
rootpw $2b$10$OvGTt1igZTMP4kfChuS5u.FIDAP./v3XyAWQwqQfn7Sa2ZIBgd9lC --iscrypted
user --name=appc --groups=wheel --password=$6$YxoySJSk3pubCXlX$3d.1giZa6zC4QwhuQXCRgvbSfGzvk7iDT4h8do2ATmaZ83E9z9H3z0TVFD3Kc2/izFbR5YYbR2sCUyQtodsKw. --iscrypted --gecos="Arseny Ratner"
sshkey --username=appc "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA7YUTXCKAMavLy98/Kep6eDKK2NyVEc/kUklZUbBubg4DfFHDO2KDXtFN7uq8HPcYR7uqFLqkRijhBwJbnPGLpp2mA+iOHLpJvD/tGpDyNt/ImM0hQG3+dzPLtvzc9Ln5mY2RUfOUTFEx7dqGVuwPQXMhZLCEkpIcGicPTpdG0CIu/GdELUtwgrZZ+reNXMG82VnFBVDZObL7H1YsmrgyyWBUMAzwf+EeUFk9Q4k8qsV8utONo3AvscaESxyt5UDvVuV7PrPxp28a03k9ybMMrXjPzuEaM2P0pxGT0VsIoR/fG78MwkSPTveX0QgDU4gBihOAcH2/2WHGBE+1pr9saw== appc@appc-pc"
#reboot
url --url=http://192.168.126.5/dvd

bootloader --append="rhgb quiet"
zerombr
clearpart --all --initlabel --drives=sda
#autopart
part /boot --ondisk=sda --asprimary --fstype="ext4" --size=1024
part pv.1 --size 8192 --grow --ondisk=sda --asprimary
volgroup vg0 pv.1 --pesize=4096
logvol swap --vgname=vg0 --size=1024 --name=lv_swap --fstype=swap
logvol / --vgname=vg0 --size=4096 --grow --maxsize=9216 --name=lv_root --fstype=ext4

network --bootproto=dhcp onboot=yes
firstboot --disable
selinux --disabled
firewall --enabled --ssh
%packages
  @^minimal-environment
  kexec-tools
%end
