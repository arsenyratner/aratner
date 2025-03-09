```bash
systemctl disable --now cloud-config.service cloud-final.service cloud-init-local.service cloud-init.service
systemctl mask cloud-config.service cloud-final.service cloud-init-local.service cloud-init.service

```

# Синхронизация времени
systemctl stop chronyd
chronyd -q "server 192.168.126.1 iburst"
systemctl start chronyd

# Создать доверительные отношения
## Windows powershell

```powershell
$mydom=aup.ds.vtg.gazprom.ru
$trustdom=gtnn.gazprom.ru
$trustshort=gtnn
$trustuser=administrator
$trustpass=QAZxsw123
$trustservers='10.20.4.5,10.20.4.6'

Add-DnsServerConditionalForwarderZone -Name "$trustdom" -ReplicationScope "Forest" -MasterServers $trustdom

netdom trust $mydom /domain:$trustdom /verify /TwoWay /verbose /userd:${$trustshort}\${$trustuser} /passwordd:$trustpass
```

## RedOS

```shell
#conditional forwarding уже создан с помощь ансибл ролью bind

mydom=gtnn.gazprom.ru
trustdom=aup.ds.vtg.gazprom.ru 
trustshort=aup
trustuser=administrator
trustpass=QAZxsw123

samba-tool domain trust create $trustdom --type=external --direction=both --create-location both -U ${trustshort}\\${trustuser}%${trustpass}
samba-tool domain trust list
```

```shell
trustdom=aup.ds.vtg.gazprom.ru
trustshort=aup
trustuser=administrator
trustpass=QAZxsw123
samba-tool domain trust list
samba-tool domain trust delete $trustdom -U ${trustshort}\\${trustuser}%${trustpass}
samba-tool domain trust create $trustdom --type=external --direction=both --create-location both -U ${trustshort}\\${trustuser}%${trustpass}
samba-tool domain trust list
```

```bash
sudo apt-get update
sudo apt-get dist-upgrade -y

# alt p11
sudo apt-get install -y mc git sshpass ansible-core ansible ansible-vim ansible-lint ansible-vim \
python3-module-ansible-collections python3-module-ansible-compat python3-module-ovirt-engine-sdk \
python3-module-proxmoxer python3-module-winrm python3-module-ovirt-imageio python3-module-ovirt-imageio-client \
qemu-tools qemu-img

# alt p10
sudo apt-get install -y mc git sshpass ansible ansible-vim ansible-lint ansible-vim \
python3-module-ovirt-engine-sdk python3-module-proxmoxer python3-module-winrm qemu-tools qemu-img

git config --global user.name "aratner"
git config --global user.email aratner@croc.ru
git config --global credential.helper store

ansible-galaxy collection install ovirt.ovirt
ansible-galaxy collection install ansible.windows

```
