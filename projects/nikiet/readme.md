# Подготовка рабочего места

## Установка WSL

```powershell

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl.exe --install

wsl.exe --update

wsl --set-default-version 2
```

## Перезапуск, перезагрузка WSL

```powershell
wsl --terminate $distro_name
wsl -d $distro_name
```

## ALSE в WSL

Необходимо конвиртировать qcow2 в tar файл
Для этого понадобится установить пакеты:
guestfs-tools qemu-img libguestfs

```bash
in_qcow="/var/tmp/alse-1.8.1uu2-base-qemu-mg15.2.0-amd64.qcow2"
out_tar="/mnt/c/vm/alse-1.8.1uu2-base.tar"
virt-tar-out -a  $in_qcow / $out_tar
```

```powershell
$distro_name = "alse-1.8"
$distro_storage = "c:\vm\_wsl\$($distro_name)"
$distro_tarball = "c:\users\aratner\downloads\alse-1.8.1uu2-base.tar"
wsl --unregister $distro_name
wsl --import $distro_name $distro_storage $distro_tarball
wsl -d $distro_name

```

### Настроим WSL Astra

```bash
apt update; apt install -y mc
wslgroups="astra-admin astra-console"
wsldelu="astra"
wsluser="astra"
wslpasswd='$6$FejUfAk2$6KnmHUyyynMKNHQi8PabYeEOOmACm7/rH/1pbeoIIWd13US35zvVvTjpH5CjQOY9XfpamObxM6KIYV1ZOOw3Z0'
for u in $wsldelu; do userdel -r -f $u; done;
useradd $wsluser --password $wslpasswd --shell /bin/bash --uid 1000 --create-home --user-group
for g in $wslgroups; do usermod -aG $g $wsluser; done;
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

## SSH

```bash
cat > ~/.ssh/config <<EOF
Host 172.26.76.218
    User k2admin
    IdentityFile ~/.ssh/k2admin.nikiet

Host 172.28.212.*
	ProxyJump k2admin@172.26.76.218
	# IdentityFile ~/.ssh/k2admin.nikiet
	# ControlPath ~/.ssh/controlmasters/%r@%h:%p
	ControlMaster auto
	ControlPersist 10m
EOF

```

## apt install

```bash
apt-get update; apt-get install -y mc ansible ansible-core 

```

