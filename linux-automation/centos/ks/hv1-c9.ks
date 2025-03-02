#
#http://www.bog.pp.ru/work/kickstart.html
lang en_US --addsupport=ru_RU
keyboard --xlayouts='us'
timezone Europe/Moscow
rootpw $2b$10$OvGTt1igZTMP4kfChuS5u.FIDAP./v3XyAWQwqQfn7Sa2ZIBgd9lC --iscrypted
user --name=appc --groups=wheel --password=$6$YxoySJSk3pubCXlX$3d.1giZa6zC4QwhuQXCRgvbSfGzvk7iDT4h8do2ATmaZ83E9z9H3z0TVFD3Kc2/izFbR5YYbR2sCUyQtodsKw. --iscrypted --gecos="Arseny Ratner"
sshkey --username=appc "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA7YUTXCKAMavLy98/Kep6eDKK2NyVEc/kUklZUbBubg4DfFHDO2KDXtFN7uq8HPcYR7uqFLqkRijhBwJbnPGLpp2mA+iOHLpJvD/tGpDyNt/ImM0hQG3+dzPLtvzc9Ln5mY2RUfOUTFEx7dqGVuwPQXMhZLCEkpIcGicPTpdG0CIu/GdELUtwgrZZ+reNXMG82VnFBVDZObL7H1YsmrgyyWBUMAzwf+EeUFk9Q4k8qsV8utONo3AvscaESxyt5UDvVuV7PrPxp28a03k9ybMMrXjPzuEaM2P0pxGT0VsIoR/fG78MwkSPTveX0QgDU4gBihOAcH2/2WHGBE+1pr9saw== appc@appc-pc"
sshkey --username=root "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA7YUTXCKAMavLy98/Kep6eDKK2NyVEc/kUklZUbBubg4DfFHDO2KDXtFN7uq8HPcYR7uqFLqkRijhBwJbnPGLpp2mA+iOHLpJvD/tGpDyNt/ImM0hQG3+dzPLtvzc9Ln5mY2RUfOUTFEx7dqGVuwPQXMhZLCEkpIcGicPTpdG0CIu/GdELUtwgrZZ+reNXMG82VnFBVDZObL7H1YsmrgyyWBUMAzwf+EeUFk9Q4k8qsV8utONo3AvscaESxyt5UDvVuV7PrPxp28a03k9ybMMrXjPzuEaM2P0pxGT0VsIoR/fG78MwkSPTveX0QgDU4gBihOAcH2/2WHGBE+1pr9saw== appc@appc-pc"

reboot
url --url=http://192.168.126.5/pub/iso/centos/9
bootloader --location=boot --append="rhgb quiet"
#sde pci-0000:00:1f.2-ata-5.0
zerombr
clearpart --all --initlabel --drives=sda,sdb,sdc,sdd,sde
#autopart
#part raid.1 --size 1 --grow --asprimary --ondisk=sda
#part raid.2 --size 1 --grow --asprimary --ondisk=sdb
#part raid.3 --size 1 --grow --asprimary --ondisk=sdc
#part raid.4 --size 1 --grow --asprimary --ondisk=sdd
#raid pv.2 --device md0 --level=RAID1 raid.1 raid.2
#raid pv.3 --device md1 --level=RAID1 raid.3 raid.4
#reqpart
#part /boot/efi --ondisk=sde --fstype=efi --grow --maxsize=200 --size=20
part /boot --size=1024 --ondisk=sde --fstype=ext4 
part pv.1 --fstype=lvmpv --size=1 --grow --ondisk=sde
volgroup vg0sys pv.1 --pesize=4096
logvol swap --vgname=vg0sys --size=1024 --name=lv_swap --fstype=swap
#logvol / --name=lv_root --size=8192 --grow --maxsize=32768 --vgname=vg0sys --fstype=xfs
#lvm thin pools
logvol none --fstype=none --size=10240 --grow --thinpool --name=tp0 --vgname=vg0sys --maxsize=102400 --metadatasize=128 --chunksize=2048
#logvol /home --name=lvt_home --size=1024 --poolname=tp0 --vgname=vg0sys --name=lvt_swap --fstype=xfs
#logvol /tmp --name=lvt_tmp --size=1024 --poolname=tp0 --vgname=vg0sys --fstype=xfs
#logvol /var --name=lvt_var --size=5120 --poolname=tp0 --vgname=vg0sys --fstype=xfs
#logvol /var/crash --name=lvt_varcrash --size=10240 --poolname=tp0 --vgname=vg0sys --fstype=xfs
#logvol /var/log --name=lvt_varlog --size=8192 --poolname=tp0 --vgname=vg0sys --fstype=xfs
#logvol /var/log/audit --name=lvt_varlogaudit --size=2048 --poolname=tp0 --vgname=vg0sys --fstype=xfs
#logvol /var/tmp --name=lvt_vartmp --size=10240 --poolname=tp0 --vgname=vg0sys --fstype=xfs
logvol / --name=lvt_root --size=8192 --poolname=tp0 --vgname=vg0sys --fstype=xfs

network --bootproto=dhcp --device=link --activate --onboot=on
network --hostname=r-hv1.r.ratners.ru

firstboot --disable
selinux --disabled
firewall --enabled --ssh
%packages
  @^minimal-environment
  kexec-tools
  mc
  vim
  cifs-utils
%end

%post --nochroot --erroronfail --log=/tmp/ks-post.log
echo post $(pwd)
issue_file="/mnt/sysimage/etc/issue"
cat $issue_file
echo "\4" >> $issue_file
echo "\6" >> $issue_file
echo "" >> $issue_file
cat $issue_file
%end

%pre --log=/tmp/ks-pre.log
echo pre
%end
