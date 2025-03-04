https://git.geco-it.net/GECO-IT-PUBLIC/Geco-Cloudbase-Init/src/branch/master/qemu-server-7.1-4/Cloudinit.pm.patch
https://wiki.geco-it.net/public:cloudbase-init


## mount qcow2

```shell
qcow2file=/mnt/d/vm/_tmp/tmp-alt-p10-ws.qcow2
modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 $qcow2file
fdisk /dev/nbd0 -l
mount /dev/nbd0p1 /mnt/tmp

mount /dev/nbd0p1 /mnt/tmp -o uid=$UID,gid=$(id -g)


umount /mnt/tmp
qemu-nbd --disconnect /dev/nbd0
rmmod nbd
```

## Create template

```shell
vmid="9012"; vmname="tmp-redos73"; qcow2file=/mnt/appc-pc/pub/templates/tmp-redos-73-20250211.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9013"; vmname="tmp-redos8"; qcow2file=/mnt/appc-pc/pub/templates/tmp-redos-8-20250211.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9020"; vmname="tmp-alt-p10-min"; qcow2file=/mnt/appc-pc/pub/templates/$vmname.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9021"; vmname="tmp-alt-p10-srv"; qcow2file=/mnt/appc-pc/pub/templates/$vmname.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9022"; vmname="tmp-alt-p10-ws"; qcow2file=/mnt/appc-pc/pub/templates/$vmname.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9025"; vmname="tmp-alt-p11-min"; qcow2file=/mnt/appc-pc/pub/templates/$vmname.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9030"; vmname="tmp-alse-1.7.6uu2-base"; qcow2file=/mnt/appc-pc/pub/templates/$vmname.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9031"; vmname="tmp-alse-1.7.6uu2-adv"; qcow2file=/mnt/appc-pc/pub/templates/$vmname.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9032"; vmname="tmp-alse-1.7.6uu2-max"; qcow2file=/mnt/appc-pc/pub/templates/$vmname.qcow2; cloneid=9000; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9102"; vmname="tmp-w2012r2std"; qcow2file=/mnt/appc-pc/pub/templates/w2012r2std-image.qcow2; cloneid=9100; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9103"; vmname="tmp-w2016std"; qcow2file=/mnt/appc-pc/pub/templates/w2016std-image.qcow2; cloneid=9100; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9104"; vmname="tmp-w2019std"; qcow2file=/mnt/appc-pc/pub/templates/w2019std-image.qcow2; cloneid=9100; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9105"; vmname="tmp-w2022std"; qcow2file=/mnt/appc-pc/pub/templates/w2022std-image.qcow2; cloneid=9100; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9110"; vmname="tmp-w10pro-21h2"; qcow2file=/mnt/appc-pc/pub/templates/$vmname.qcow2; cloneid=9100; qcow2storage=local-zfs; qcow2options=",cache=writeback"
vmid="9111"; vmname="tmp-w11pro-24h2"; qcow2file=/mnt/appc-pc/pub/templates/tmp-w11pro-24h2-202502.qcow2; cloneid=9100; qcow2storage=local-zfs; qcow2options=",cache=writeback"

qm destroy $vmid; \
qm clone $cloneid $vmid --full 1 --name $vmname; \
qm importdisk $vmid $qcow2file $qcow2storage; \
qm set $vmid --virtio0 $qcow2storage:vm-${vmid}-disk-0${qcow2options}; \
qm set $vmid --boot c --bootdisk virtio0 ; \
qm resize $vmid virtio0 +2G ; \
qm template $vmid

qm destroy $vmid; qm clone $cloneid $vmid --full 1 --name $vmname; qm importdisk $vmid $qcow2file $qcow2storage; qm set $vmid --virtio0 $qcow2storage:vm-${vmid}-disk-0${qcow2options}; qm set $vmid --boot c --bootdisk virtio0 ; qm resize $vmid virtio0 +2G ; qm template $vmid


declare -a vmarr=(
  "9102,tmp-w2012r2std"
  "9103,tmp-w2016std"
  "9104,tmp-w2019std"
  "9105,tmp-w2022std"
  "9110,tmp-w10pro-21h2"
  "9111,tmp-w11pro-24h2"
)
qcow2storage=local-zfs; qcow2options=",cache=writeback"
for vm in "${vmarr[@]}"
do
  VMIN=(${vm//,/ })
  vmid=${VMIN[0]} 
  vmname=${VMIN[1]}
  qcowfile=/mnt/appc-pc/pub/templates/$vmname.qcow2
  qm destroy $vmid; qm clone $cloneid $vmid --full 1 --name $vmname; qm importdisk $vmid $qcow2file $qcow2storage; qm set $vmid --virtio0 $qcow2storage:vm-${vmid}-disk-0${qcow2options}; qm set $vmid --boot c --bootdisk virtio0 ; qm resize $vmid virtio0 +2G ; qm template $vmid
done

```

## Удалить ВМ

```shell
vmids="9105 9106 9103 9104 9102 9101 9010 9011 9007 9006 9005 9009 9002 9001 9016 9013 9014 9008"; for vmid in $vmids; do qm destroy $vmid; done
```

## Удалить снапшоты

```shell
zfs list -H -o name -t snapshot | xargs -n1 zfs destroy
``` 

## Доустановить пакеты в образ
```shell
zdev=/dev/zvol/rpool/data/base-9016-disk-0
zpart=${device}-part1
zmnt=/mnt/tmp
sudo fdisk ${zdev}
sudo e2fsck -f ${zpart}
sudo resize2fs ${zpart}
sudo mount ${zpart} ${zmnt}
sudo chroot ${zmnt} apt update; 
sudo chroot ${zmnt} apt install -y python3-apt aptitude astra-update
sudo chroot ${zmnt} apt install -y fly-all-main
```

## Прочая фигня

```shell
devices="sdc sdd"
for device in $devices; do
  echo $device
  wipefs -a -f /dev/${device}
  dd if=/dev/zero of=/dev/$device bs=1M count=1
  parted --script /dev/$device "mklabel gpt"  
  parted --script /dev/$device "mkpart primary 0% 25%"
  parted --script /dev/$device "mkpart primary 25% 85%"
done

zpool add rpool log mirror /dev/sdc1 /dev/sdd1 cache /dev/sdc2 /dev/sdd2

qpvesm add cifs zz-backup --server 192.168.126.5 --share backup --subdir /r-pve1 --username nmt --password 19871979
qpvesm add cifs zz-images --server 192.168.126.5 --share pub --subdir /iso --username nmt --password 19871979
# --smbversion 3

vmid="103"
vmname="r-vm-w10p1"
vmmem=4096
vmos="win10"
hddstorage=local-zfs
isostorage="appc-pc"

qm create \
  $vmid \
  --cdrom $isostorage:iso/en-us_windows_10_business_editions_version_22h2_updated_march_2023_x64_dvd_94a1087a.iso \
  --name $vmname \
  --vlan0 virtio=62:57:BC:A2:0E:18 \
  --virtio0 ${hddstorage}:vm-${vmid}-disk-0,cache=writeback,discard=on,iothread=1,size=32G \ 
  --bootdisk virtio0 \
  --ostype $vmos \
  --memory $vmmem \
  --onboot no \
  --sockets 1

qm clone <vmid> <newid>

--format <qcow2 | raw | vmdk>
``` 

## create vm convert to template

```shell
vmid="9000"
vmname="tmp"
vmmemory="512"
vmbridge="vmbr0"
vmostype="l26"
#qm destroy $vmid
qm create ${vmid} \
--name $vmname \
--template 1 \
--sockets 1 \
--cores 2 \
--memory 512 \
--scsihw virtio-scsi-pci \
--net0 virtio,bridge=$vmbridge,firewall=1

#convert to template
qm template $vmid
```

## create VM
```shell
vmid="1900"
vmname="tmp"
vmmemory=512
vmostype="win10"
hddstor="local-zfs"
isostor="appc-pc"

qm create ${vmid}
--name $vmname
--boot order=virtio0;ide2;net0
--sockets 1
--cores 3
--ide2 appc-pc:iso/en-us_windows_10_business_editions_version_22h2_updated_march_2023_x64_dvd_94a1087a.iso,media=cdrom
--memory $vmmemory
--net0 virtio,bridge=vmbr0,firewall=1
--ostype $vmostype
--scsihw virtio-scsi-single
--virtio0 $hddstor:vm-${vmid}-disk-0,cache=writeback,discard=on,iothread=1,size=32G

machine: pc-i440fx-8.0
meta: creation-qemu=8.0.2,ctime=1695756298
smbios1: uuid=4b36f4f4-b155-4056-bc5a-f225a89bb63c
vmgenid: 3d36d5cb-ad37-45ec-a601-0529ad33a8ce
--autostart
```

## загрузить диск для шаблона ВМ

```shell
vmid=113
qcow2file=/mnt/appc-pc/pub/iso/astra/alse-vanilla-1.7.4uu1-cloud-base-mg12.0.1.qcow2
qcow2storage="rpool"
qcow2options=",cache=writeback"
qm importdisk $vmid $qcow2file rpool; qm set $vmid --virtio0 $qcow2storage:vm-${vmid}-disk-0${qcow2options}; qm set $vmid --boot c --bootdisk virtio0

--bios ovmf

#alt
qcow2storage="local-zfs"
qcow2options=",cache=writeback"
cipass='$5$9x5KUXMz$j9/uV8HbGhTUgz4.yn4rIiTPlCZ1IUEhw6WJZ.U9.G4'
ciuser="appc"
cipubkey="/var/tmp/appc.pub"

vmid="9004"
vmname="tmp-alse-1.7.4"
qcow2file=/mnt/appc-pc/pub/iso/ubuntu/22.04-jammy-server-cloudimg-amd64.img

qm create $vmid \
  --name $vmname \
  --template 1 \
  --sockets 1 \
  --cores 2 \
  --memory 2048 \
  --machine q35 \
  --bios seabios \
  --net0 virtio,bridge=vmbr0 \
  --boot c \
  --bootdisk virtio0 \
  --scsihw virtio-scsi-pci \
  --ostype l26 \
  --vga qxl,memory=16 \
  --ide2 $qcow2storage:cloudinit \
  --sshkeys $cipubkey --citype nocloud --ciuser $ciuser --cipass $cipass --ciupgrade 0 \
  --virtio0 $qcow2storage:0${qcow2options},import-from=$qcow2file


sleep 10
mount /dev/zvol/rpool/data/vm-${vmid}-disk-0-part1 /mnt/tmp
echo "" >> /mnt/tmp/etc/issue
echo "\4" >> /mnt/tmp/etc/issue
echo "\6" >> /mnt/tmp/etc/issue
echo "" >> /mnt/tmp/etc/issue
umount /mnt/tmp
sleep 10
qm resize $vmid virtio0 +7G
``` 
