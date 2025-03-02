# RAID MD
https://raid.wiki.kernel.org/index.php/A_guide_to_mdadm
https://knowledgebase.starwindsoftware.com/guidance/recommended-raid-settings-for-hdd-and-ssd-disks/
RAID Level   Chunk size for HDD Arrays   Chunk size for SSD Arrays
0                    Disk quantity * 4Kb                Disk quantity * 8Kb
5                    (Disk quantity – 1) * 4Kb        (Disk quantity – 1) * 8Kb
6                    (Disk quantity – 2) * 4Kb        (Disk quantity – 2) * 8Kb
10                  (Disk quantity * 4Kb)/2          (Disk quantity * 8Kb)/2

```
devices="sda sdb sdc sdd"
slowdisk1="/dev/sda1"
slowdisk2="/dev/sdb1"
fastdisk1="/dev/sdc1"
fastdisk2="/dev/sdd1"
slowmd="/dev/md0"
fastmd="/dev/md1"

for device in $devices; do
  echo $device
  dd if=/dev/zero of=/dev/$device bs=1M count=1
  parted --script /dev/$device "mklabel gpt"  
  parted --script /dev/$device "mkpart primary 0% 100%"
  parted --script /dev/$device "set 1 raid on" 
done

mdadm --create --force --verbose --assume-clean $slowmd --level=1 --raid-devices=2 $slowdisk1 $slowdisk2
mdadm --create --force --verbose --assume-clean $fastmd --level=1 --raid-devices=2 $fastdisk1 $fastdisk2

```

# LVM Cache

## varaiables
```
lvcache_slowdev=$slowmd
lvcache_fastdev=$fastmd
lvcache_vgname="vg1data"
lvcache_lv0_thin="tp0"
lvcache_lv1_data="lv_vm"
lvcache_lv1_data_size="1024G"
lvcache_lv1_cache="lv_vm_cache"
lvcache_lv1_cache_size="200G"
lvcache_lv1_cache_meta="lv_vm_cache_meta"
lvcache_lv1_cache_meta_size="2G"

```
## create VG 
```
pvcreate $lvcache_slowdev
pvcreate "$lvcache_fastdev"
vgcreate $lvcache_vgname $lvcache_slowdev $lvcache_fastdev
```
## create LV
```
lvcreate -L $lvcache_lv1_data_size -n $lvcache_lv1_data $lvcache_vgname $lvcache_slowdev
lvcreate -L $lvcache_lv1_cache_size -n $lvcache_lv1_cache $lvcache_vgname $lvcache_fastdev
lvcreate -L $lvcache_lv1_cache_meta_size -n $lvcache_lv1_cache_meta $lvcache_vgname $lvcache_fastdev
lvconvert --type cache-pool --cachemode writeback --poolmetadata $lvcache_vgname/$lvcache_lv1_cache_meta $lvcache_vgname/$lvcache_lv1_cache
lvs -a -o +devices

lvconvert --type cache --cachepool $lvcache_vgname/$lvcache_lv1_cache $lvcache_vgname/$lvcache_lv1_data
lvs -a -o +devices

mkfs -t ext4 /dev/$lvcache_vgname/$lvcache_lv1_data
mkdir /vm
echo /dev/$lvcache_vgname/$lvcache_lv1_data /vm ext4 defaults 0 0 >> /etc/fstab
systemctl daemon-reload
mount -a 


```
