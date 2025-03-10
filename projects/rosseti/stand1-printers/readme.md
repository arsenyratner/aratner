# ALT Linux в WSL

Нам нужен tar файл из архива:
https://ftp.altlinux.org/pub/distributions/ALTLinux/p11/images/cloud/x86_64/alt-p11-rootfs-systemd-x86_64.tar.xz


```powershell
$distro_name = "alt-p11"
$distro_storage = "c:\vm\_wsl\$($distro_name)"
$distro_tarball = "c:\users\public\iso\alt-p11-rootfs-systemd-x86_64.tar"

7z e c:\users\public\iso\alt-p11-rootfs-systemd-x86_64.tar.xz

wsl --unregister $distro_name
wsl --import $distro_name $distro_storage $distro_tarball
wsl -d alt-p11

```

```bash
apt-get update; apt-get install -y passwd sudo 

wsluser=appc
adduser -G wheel $wsluser
echo -e "$wsluser ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$wsluser
passwd $wsluser

cat > /etc/wsl.conf <<EOF
[user]
default=$wsluser

[automount]
enabled = true
mountFsTab = false
root = /mnt/
options = "metadata,umask=22,fmask=11"

[network]
generateHosts = true
generateResolvConf = true
EOF

```

```powershell
wsl --terminate $distro_name
wsl -d $distro_name

```

```bash
sudo apt-get update
sudo apt-get dist-upgrade -y

sudo apt-get install -y mc git sshpass ansible-core ansible ansible-lint ansible-vim python3-module-ansible-collections python3-module-ansible-compat python3-module-ovirt-engine-sdk python3-module-proxmoxer

ansible-galaxy collection install ovirt.ovirt

```
