## Установка WSL

```powershell

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl.exe --install

wsl.exe --update

wsl --set-default-version 2


```

## Установка Alt Linux в WSL

### Установка Alt P11

```powershell
$distro_name = "alt-p11"
$distro_storage = "c:\vm\_wsl\$($distro_name)"
$distro_tarball = "c:\users\public\iso\alt-p11-rootfs-systemd-x86_64.tar"
wsl --unregister $distro_name
wsl --import $distro_name $distro_storage $distro_tarball
wsl -d $distro_name
```

### Установка Alt P10

```powershell
$distro_name = "alt-p10"
$distro_storage = "c:\vm\_wsl\$($distro_name)"
$distro_tarball = "D:\Users\Public\iso\alt\alt-p10-rootfs-systemd-x86_64.tar"
wsl --unregister $distro_name
wsl --import $distro_name $distro_storage $distro_tarball
wsl -d $distro_name
```

### Настроим WSL

Обновим пакеы, создадим пользователя с паролем и настроим WSL чтобы поумолчанию стартовала под этим пользователем. Настроил так чтобы хостовый диск монтировался с правами не 777 и можно было бы назначать права на файлы.

```bash
apt-get update; apt-get install -y passwd sudo
wsluser=appc
wslpasswd='$6$FejUfAk2$6KnmHUyyynMKNHQi8PabYeEOOmACm7/rH/1pbeoIIWd13US35zvVvTjpH5CjQOY9XfpamObxM6KIYV1ZOOw3Z0'
adduser $wsluser --password $wslpasswd
usermod -aG wheel $wsluser
echo -e "$wsluser ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$wsluser
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

### Перезапустим WSL

```powershell
wsl --terminate $distro_name
wsl -d $distro_name
```
