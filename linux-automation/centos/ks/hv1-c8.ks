lang en_US --addsupport=ru_RU
keyboard --xlayouts='us'
timezone Europe/Moscow --utc
rootpw $2b$10$OvGTt1igZTMP4kfChuS5u.FIDAP./v3XyAWQwqQfn7Sa2ZIBgd9lC --iscrypted
user --name=appc --groups=wheel --password=$6$YxoySJSk3pubCXlX$3d.1giZa6zC4QwhuQXCRgvbSfGzvk7iDT4h8do2ATmaZ83E9z9H3z0TVFD3Kc2/izFbR5YYbR2sCUyQtodsKw. --iscrypted --gecos="Arseny Ratner"
sshkey --username=appc "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA7YUTXCKAMavLy98/Kep6eDKK2NyVEc/kUklZUbBubg4DfFHDO2KDXtFN7uq8HPcYR7uqFLqkRijhBwJbnPGLpp2mA+iOHLpJvD/tGpDyNt/ImM0hQG3+dzPLtvzc9Ln5mY2RUfOUTFEx7dqGVuwPQXMhZLCEkpIcGicPTpdG0CIu/GdELUtwgrZZ+reNXMG82VnFBVDZObL7H1YsmrgyyWBUMAzwf+EeUFk9Q4k8qsV8utONo3AvscaESxyt5UDvVuV7PrPxp28a03k9ybMMrXjPzuEaM2P0pxGT0VsIoR/fG78MwkSPTveX0QgDU4gBihOAcH2/2WHGBE+1pr9saw== appc@appc-pc"

reboot
url --url=http://192.168.126.5/dvd

bootloader --append="rhgb quiet"
#sde pci-0000:00:1f.2-ata-5.0
#clearpart --drives=sde --initlabel
clearpart --all --initlabel --drives=sde
zerombr
#part /boot --asprimary --fstype="ext4" --size=1024 --ondisk=/dev/disk/by-path/pci-0000:00:1f.2-ata-5.0
part /boot --asprimary --fstype="ext4" --size=1024 --ondisk=sde
#part pv.1 --size 8192 --grow --asprimary --ondisk=/dev/disk/by-path/pci-0000:00:1f.2-ata-5.0
part pv.1 --size 8192 --grow --asprimary --ondisk=sde
volgroup vg0-sys pv.1 --pesize=4096
logvol swap --vgname=vg0-sys --size=8192 --name=lv_swap --fstype=swap
logvol / --vgname=vg0-sys --size=4096 --grow --name=lv_root --fstype=ext4 --maxsize=9216 

#network --bootproto=dhcp
network --bootproto=dhcp --device=link --activate --onboot=on
network --hostname=r-hv1.r.ratners.ru

firstboot --disable
selinux --disabled
firewall --enabled --ssh
%packages
  @^minimal-environment
  kexec-tools
%end

%pre --log=/tmp/ks-pre.log
	echo prescript
	#wipefs -a -f /dev/sde
	#wipefs -a -f /dev/disk/by-path/pci-0000:00:1f.2-ata-5.0
	#udevadm settle
	#dmsetup remove_all
	
	# De-activate any exiting Volume Groups
	#vgchange -an system
	#vgchange -an os
	
	# Clear software raid devices if any
	#raid_devices=$(mktemp /tmp/mdstat.XXXXXXXXX)
	#cat /proc/mdstat | grep ^md | cut -d : -f 1 > $raid_devices
	#if [ -s $raid_devices ];then
	#for raid in `cat $raid_devices`;do
	#	wipefs -f -a /dev/$raid
	#	mdadm --stop -f /dev/$raid
	#	if [ $? != "0" ];then
	#		udevadm settle
	#		dmsetup remove_all
	#		mdadm --stop -f /dev/$raid
	#	fi
	#done
	#else
	#echo "All raid devices are cleared"
	#fi
	#rm -vf $raid_devices
	
	# Wipe any partitions if found
	#available_disks=$(mktemp /tmp/disks.XXXXXXXXX)
	#ls -r /dev/sd* > $available_disks
	#for disk in `cat $available_disks`;do
	#	wipefs -f -a $disk
	#done
	#rm -vf $available_disks
%end
%post --log=/tmp/ks-post.log
	echo postscript
%end
